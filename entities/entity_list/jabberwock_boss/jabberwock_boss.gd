class_name JabberwockBoss
extends Enemy

const RAGE_COMBO_BASE_THRESHOLD: float = 0.3

@export var seed_damage: int = 3
@export var bomb_damage: int = 5
@export var swipe_pushback: float = 1200.0
@export var sweep_pushback: float = 2000.0
@export var projectile_spawnpoint: Marker3D

var pushback: bool = false
var pushback_speed: float

@onready var sweep: AttackObject = %Sweep
@onready var swipe: AttackObject = %Swipe
@onready var swipe_mirrored: AttackObject = %SwipeMirrored
@onready var breath: AttackObject = %LightningBreath
@onready var rage_component: JabberwockBossRageComponent = %RageComponent
@onready var lightning_breath_particles: GPUParticles3D = %LightningBreathParticles


func prepare_states():
	var boss_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", JabberwockBossIdle.new(self, rage_component)),
		StateInitializer.new(&"Shoot", JabberwockBossShoot.new(self, rage_component, breath)),
		StateInitializer.new(&"Sweep", JabberwockBossSweep.new(self, rage_component, sweep)),
		StateInitializer.new(&"Swipe", JabberwockBossSwipe.new(self, rage_component, swipe, swipe_mirrored)),
		#StateInitializer.new(&"BigSwipe"
		StateInitializer.new(&"Death", DeathState.new(
			self, 
			"jabberwock/death",
			death_state_duration
			))
	]
	
	state_machine.assign_states(boss_states)

func _physics_process(delta: float) -> void:
	super(delta)
	rage_component.decay_rage(delta)


func _on_hurtbox_hit_received(attack_object: AttackObject, invin: bool) -> void:
	if !invin:
		rage_component.increase_rage()
		play_sound_fx(&"damaged")
		#play_sound_fx(&"damaged_roar")
		hurt_effect()
		resolve_hit(attack_object)

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	RunStats.jabberwocks_defeated += 1
	enemy_killed.emit(self)
	hurtbox.set_collision_mask_value(2, 0)

	breath.hitbox.monitorable = false
	sweep.hitbox.monitorable = false
	swipe.hitbox.monitorable = false
	swipe_mirrored.hitbox.monitorable = false
	
	state_machine.change_state(&"Death")

func can_combo() -> bool:
	if rage_component.current_rage < rage_component.RAGE_COST_TO_COMBO:
		return false
	
	var chance: float = randf()
	var rage_chance_increase: float = (rage_component.current_rage - rage_component.RAGE_COST_TO_COMBO) / 200.0
	var threshold: float = RAGE_COMBO_BASE_THRESHOLD + rage_chance_increase
	
	"""
	print(threshold, " ",chance)
	if chance <= threshold:
		print("combo")
	else:
		print("no combo")
	"""
	
	return chance <= threshold
