class_name CaterpillarEnemy
extends Enemy

@export var seed: Resource
@export var seed_damage: int = 4
@export var crawl_duration: float = 2.0
@export var change_direction_timestamp: float = 1.2
@export var shooting_range: float = 17.0
@export var shoot_times: Array[float] = [0.7, 1.6]
@export var warning_times: Array[float] = [0.1, 0.9]

@onready var ray_cast: RayCast3D = %ray_cast


func prepare_states():
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", CaterpillarEnemyIdle.new(self)),
		StateInitializer.new(&"Crawl", CaterpillarEnemyCrawl.new(self, ray_cast)),
		StateInitializer.new(&"Shoot", CaterpillarEnemyShoot.new(self, ray_cast)),
		StateInitializer.new(&"Death", DeathState.new(
			self, 
			"caterpillar/death", # change later
			death_state_duration
			))
	]

	state_machine.assign_states(enemy_states)

func _on_hurtbox_hit_received(attack_object: AttackObject, invin: bool) -> void:
	if !invin:
		play_sound_fx(&"damaged")
		play_sound_fx(&"damaged_squeal")
		hurt_effect()
		resolve_hit(attack_object)

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	super(args)
	RunStats.enemies_killed += 1
	state_machine.change_state(&"Death")
