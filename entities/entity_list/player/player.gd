class_name Player
extends CharacterEntity

signal player_died(player: Player)
signal player_damage_taken(player: Player, damage: int)
signal player_hp_recovered(player: Player)
signal obtained_money(amount: int)

const DODGE_REQUIREMENT: float = 50
const PARRY_REQUIREMENT: float = 20

@export var hurtbox: HurtboxComponent
@export var animation_tree: AnimationTree
@export var dodge_duration: float
@export var dodge_speed: float
@export var attack_move_speed: float
@export var base_parry_invincibility_period: float
@export var parry_duration: float

# Mainly used when hitting the red knight during its block period
var deflect_velocity: Vector3 = Vector3.ZERO
var deflect_decay: float = 0.0 # How much deflect reduces by absolutely every second
var deflect_direction: Vector3 = Vector3.ZERO

# Required for parrying/dodging
var stamina: float = 100.0
var max_stamina: float = 100.0
var regenerating_stamina: bool = true
var stamina_regeneration_cooldown: SceneTreeTimer = null
var parry_counter: int = 0
var can_get_parry_point: bool = false
var upgrades: PlayerUpgrades

@export var title: bool = false

@onready var parry_particles: GPUParticles3D = %ParryParticles
@onready var action_animator: AnimationPlayer = %ActionAnimator
@onready var basic_attack: AttackObject = %basic_attack
@onready var camera: LevelCamera
@onready var listener: AudioListener3D = %listener

@onready var bleed_particles: GPUParticles3D = %BleedParticles
@onready var paralysis_particles: GPUParticles3D = %ParalysisParticles
@onready var burn_particles: GPUParticles3D = %BurnParticles
@onready var damaged_particles: GPUParticles3D = %DamagedParticles

func _ready() -> void:
	prepare_states()
	hurtbox.hit_parried.connect(parry_received)

func _physics_process(delta: float) -> void:
	super(delta)
	update_listener_direction()
	deflect_velocity = deflect_velocity.move_toward(Vector3.ZERO, deflect_decay * delta)

	#print(health_component.current_health)
	if regenerating_stamina:
		stamina = minf(stamina + delta * 100.0, max_stamina)

func prepare_states():
	if title:
		return
	# The & before string declarations marks it as a StringName, which is a
	# separate class that is much faster for string comparisons.
	var player_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", PlayerIdle.new(self)),
		StateInitializer.new(&"Walk", PlayerWalk.new(self)),
		StateInitializer.new(&"Dodge", PlayerDodge.new(self)),
		StateInitializer.new(&"Parry", PlayerParry.new(self)),
		StateInitializer.new(&"Attack", PlayerBasicAttack.new(self, basic_attack)),
		StateInitializer.new(&"Death", PlayerDeath.new(self))
	]
	
	state_machine.assign_states(player_states)

# Any code that has to be run on initializing a character scene
# involving upgrades
func initialize_upgrades(_upgrades: PlayerUpgrades):
	upgrades = _upgrades
	health_component.max_health = health_component.base_max_health + upgrades.extra_hp * upgrades.EXTRA_HP_AMOUNT
	max_stamina = 100.0 + upgrades.extra_stamina * upgrades.EXTRA_STAMINA_AMOUNT

# regeneration_cooldown is the amount of time before stamina starts regenerating again
# is overwritten whenever another stamina action is taken
func consume_stamina(amount: int, regeneration_cooldown: float):
	regenerating_stamina = false
	stamina -= amount
	
	var new_timer: bool = !stamina_regeneration_cooldown
	if stamina_regeneration_cooldown:
		new_timer = stamina_regeneration_cooldown.time_left == 0.0
		if !new_timer:
			stamina_regeneration_cooldown.time_left = regeneration_cooldown
	
	if new_timer:
		stamina_regeneration_cooldown = get_tree().create_timer(regeneration_cooldown)
		stamina_regeneration_cooldown.timeout.connect(enable_stamina_regen)

func enable_stamina_regen():
	regenerating_stamina = true

func can_dodge():
	return stamina > 0.0

func can_parry():
	return stamina > 0.0

func parry_received(attack_object: AttackObject):
	if can_get_parry_point:
		parry_counter = mini(parry_counter + 1, 3)
		can_get_parry_point = false
		play_sound_fx(&"parried")
	
		if attack_object.entity is JabberwockBoss && attack_object.entity.pushback:
			deflect_velocity = deflect_direction * attack_object.entity.pushback_speed
			deflect_decay = attack_object.entity.pushback_speed * 2.75
	
	parry_hitstop()

func parry_hitstop():
	var timer: SceneTreeTimer = get_tree().create_timer(0.05, true, true, true)
	timer.timeout.connect(finish_parry_hitstop)
	Engine.time_scale = 0.01

func finish_parry_hitstop():
	Engine.time_scale = 1.0
	parry_particles.emitting = true
	parry_particles.restart()

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	Bgm.fadeout_bgm(0.5)
	inflicted_attack_effects.clear()
	player_died.emit(self)
	state_machine.change_state(&"Death")

func heal(heal_amount: int, emit: bool = true):
	health_component.set_current_health(health_component.current_health + heal_amount)
	if emit:
		player_hp_recovered.emit(self)
	#player_damage_taken.emit(self, 0)

func gain_money(amount: int):
	obtained_money.emit(amount)
	play_sound_fx(&"gain_money")

func _on_hurtbox_hit_received(attack_object: AttackObject, invin: bool) -> void:
	if !invin:
		RunStats.hits_taken += 1
		#print("here")
		play_sound_fx(&"damaged")
		resolve_hit(attack_object)
		
		if attack_object.entity is JabberwockBoss && attack_object.entity.pushback:
			deflect_velocity = deflect_direction * attack_object.entity.pushback_speed
			deflect_decay = attack_object.entity.pushback_speed * 2.75

func update_listener_direction():
	listener.global_rotation.y = Vector2(-0.707107, 0.707107).angle() + deg_to_rad(90)
