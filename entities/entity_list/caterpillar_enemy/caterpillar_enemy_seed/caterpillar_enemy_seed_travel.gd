class_name CaterpillarEnemySeedTravel
extends ProjectileState

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

	if ray_cast.is_colliding():
		var collider: Object = ray_cast.get_collider()
		if collider.get_collision_layer_value(5):
			return state_machine.change_state(&"Explode", {"hit_player": true})
		else:
			return state_machine.change_state(&"Explode")

	if delta_count >= proj.time_to_live:
		return state_machine.change_state(&"Explode")
	
	proj.velocity = direction * proj.movement_component.move_speed * delta
	proj.move_and_slide()

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	pass
