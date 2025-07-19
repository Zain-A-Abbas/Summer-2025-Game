class_name CaterpillarEnemySeedExplode
extends ProjectileState

const SEED = preload("res://entities/entity_list/caterpillar_enemy/caterpillar_enemy_seed/caterpillar_enemy_seed.tscn")
const IDLE_TIME: float = 1.2

var projectiles: Node3D
var starting_dir: Vector3
var seed_direction: Vector3
var delta_count: float = 0.0
var exploded: bool = false

func _init(new_seed: CaterpillarEnemySeed, projs: Node3D, dir: Vector3) -> void:
	proj = new_seed
	projectiles = projs
	starting_dir = dir

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	if args.has("hit_player") && !proj.is_child:
		proj.is_child = true

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	if !proj.is_child:
		if !exploded:
			for n in 4: # create 4 new seeds
				# initialize directions
				if n == 0:
					seed_direction = starting_dir.rotated(Vector3.UP, deg_to_rad(45))
				else:
					seed_direction = seed_direction.rotated(Vector3.UP, deg_to_rad(90 * n))
				
				var seed = SEED.instantiate()
				projectiles.add_child(seed)
				seed.initialize_seed(true, Vector3(seed_direction.x, 0.0, seed_direction.z), projectiles, proj.atk_obj.attack_effects[0].damage)
				seed.global_position = proj.global_position
	
	if !exploded:		
		proj.play_sound_fx(&"death")
		proj.atk_obj.hitbox.monitorable = false
		proj.hide()
		exploded = true
	
	if delta_count >= IDLE_TIME:
		proj.char_entity_die()
