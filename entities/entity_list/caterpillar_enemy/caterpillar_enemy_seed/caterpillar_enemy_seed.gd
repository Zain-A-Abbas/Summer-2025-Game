class_name CaterpillarEnemySeed
extends CharacterEntity

@onready var atk_obj: AttackObject = %Hitbox

var is_child: bool = false
var direction: Vector3 = Vector3.ZERO
var projectiles: Node3D

func initialize_seed(child: bool, dir: Vector3, projs: Node3D) -> void:
	is_child = child
	direction = dir
	projectiles = projs
	atk_obj.hitbox.monitorable = true
	prepare_states()

func prepare_states():
	var seed_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", CaterpillarEnemySeedIdle.new(self)),
		StateInitializer.new(&"Travel", CaterpillarEnemySeedTravel.new(self, direction)),
		StateInitializer.new(&"Explode", CaterpillarEnemySeedExplode.new(self, is_child, projectiles, direction))
	]
	
	state_machine.assign_states(seed_states)

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	queue_free()
