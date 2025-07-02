class_name CaterpillarEnemySeedExplode
extends ProjectileState

const SEED = preload("res://entities/entity_list/caterpillar_enemy/caterpillar_enemy_seed/caterpillar_enemy_seed.tscn")

var delta_count: float = 0
var is_child: bool = false
var projectiles: Node3D
var starting_dir: Vector3
var seed_direction: Vector3

func _init(new_seed: CaterpillarEnemySeed, child: bool, projs: Node3D, dir: Vector3) -> void:
	proj = new_seed
	is_child = child
	projectiles = projs
	starting_dir = dir

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0

func st_physics_process(delta: float) -> void:
	if !is_child: # create 4 new seeds
		for n in 4: # initialize directions
			if n == 0:
				seed_direction = starting_dir.rotated(Vector3(0, 1, 0), deg_to_rad(45))
			else:
				seed_direction = seed_direction.rotated(Vector3(0, 1, 0), deg_to_rad(90 * n))
			
			var seed = SEED.instantiate()
			projectiles.add_child(seed)
			seed.initialize_seed(true, seed_direction, projectiles)
			seed.global_position = proj.global_position
			
	proj.char_entity_die()

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	pass
