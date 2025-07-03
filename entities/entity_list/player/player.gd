class_name Player
extends CharacterEntity

signal player_damage_taken(player: Player, damage: int)
signal player_hp_recovered(player: Player)
signal obtained_money(amount: int)

const DODGE_REQUIREMENT: float = 50
const PARRY_REQUIREMENT: float = 20

@onready var action_animator: AnimationPlayer = %ActionAnimator
@onready var basic_attack: AttackObject = %basic_attack

@export var hurtbox: HurtboxComponent
@export var animation_tree: AnimationTree

# Required for parrying/dodging
var stamina: float = 100.0
var max_stamina: float = 100.0
var regenerating_stamina: bool = true
var stamina_regeneration_cooldown: SceneTreeTimer = null
var parry_counter: int = 0
var can_get_parry_point: bool = false
var upgrades: PlayerUpgrades

func _ready() -> void:
	prepare_states()
	hurtbox.hit_parried.connect(parry_received)

func _physics_process(delta: float) -> void:
	if regenerating_stamina:
		stamina = minf(stamina + delta * 100.0, max_stamina)

func prepare_states():
	# The & before string declarations marks it as a StringName, which is a
	# separate class that is much faster for string comparisons.
	var player_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", PlayerIdle.new(self)),
		StateInitializer.new(&"Walk", PlayerWalk.new(self)),
		StateInitializer.new(&"Dodge", PlayerDodge.new(self)),
		StateInitializer.new(&"Parry", PlayerParry.new(self)),
		StateInitializer.new(&"Attack", PlayerBasicAttack.new(self, basic_attack))
	]
	
	state_machine.assign_states(player_states)

# Any code that has to be run on initializing a character scene
# involving upgrades
func initialize_upgrades(_upgrades: PlayerUpgrades):
	upgrades = _upgrades
	health_component.max_health = 100 + upgrades.extra_hp * upgrades.EXTRA_HP_AMOUNT
	max_stamina = 100 + upgrades.extra_stamina * upgrades.EXTRA_STAMINA_AMOUNT

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

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	pass

func heal(heal_amount: int):
	health_component.current_health = clampi(health_component.current_health + heal_amount, 0, health_component.max_health)
	player_hp_recovered.emit(self)

func gain_money(amount: int):
	obtained_money.emit(amount)

func _on_hurtbox_hit_received(attack_object: AttackObject) -> void:
	#print("player hit")
	resolve_hit(attack_object)
