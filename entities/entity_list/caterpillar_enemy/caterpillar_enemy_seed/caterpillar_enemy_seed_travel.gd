class_name CaterpillarEnemySeedTravel
extends ProjectileState

const TTL: float = 1.1

var delta_count: float = 0.0
var direction: Vector3
var ray_cast: RayCast3D

func _init(new_seed: CaterpillarEnemySeed, ray: RayCast3D, dir: Vector3) -> void:
	proj = new_seed
	direction = dir
	ray_cast = ray

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	proj.face_direction(direction)

func st_physics_process(delta: float) -> void:
	delta_count += delta

	if delta_count >= TTL || ray_cast.is_colliding():
		return state_machine.change_state(&"Explode")
	
	proj.velocity = direction * proj.movement_component.move_speed * delta
	proj.move_and_slide()

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	pass
