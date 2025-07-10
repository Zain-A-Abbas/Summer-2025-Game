class_name JabberwockBoss
extends Enemy

@onready var sweep: AttackObject = %Sweep
@onready var swipe: AttackObject = %Swipe
@onready var swipe_mirrored: AttackObject = %SwipeMirrored
@onready var breath: AttackObject = %LightningBreath
@onready var rage_component: JabberwockBossRageComponent = %RageComponent
@onready var projectile_spawnpoint: Marker3D = %ProjectileSpawnpoint
@onready var lightning_breath_particles: GPUParticles3D = %LightningBreathParticles


func prepare_states():
	var boss_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", JabberwockBossIdle.new(self, rage_component)),
		StateInitializer.new(&"Move", JabberwockBossMove.new(self, rage_component)),
		StateInitializer.new(&"Shoot", JabberwockBossShoot.new(self, rage_component, breath)),
		StateInitializer.new(&"Sweep", JabberwockBossSweep.new(self, rage_component, sweep)),
		StateInitializer.new(&"Swipe", JabberwockBossSwipe.new(self, rage_component, swipe, swipe_mirrored)),
		StateInitializer.new(&"Death", DeathState.new(
			self, 
			"jabberwock/death", # change later
			death_state_duration
			))
	]
	
	state_machine.assign_states(boss_states)

func _on_hurtbox_hit_received(attack_object: AttackObject, invin: bool) -> void:
	if !invin:
		rage_component.increase_rage()
		hurt_effect()
		resolve_hit(attack_object)

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	enemy_killed.emit(self)
	queue_free()

func can_combo() -> bool:
	if rage_component.current_rage < rage_component.RAGE_COST_TO_COMBO:
		return false
	
	var chance: int = randi_range(1, 10)
	var rage_chance_increase: int = roundf((rage_component.current_rage - rage_component.RAGE_COST_TO_COMBO) / 100.0)
	var threshold: int = 7 - rage_chance_increase
	
	return chance > threshold
