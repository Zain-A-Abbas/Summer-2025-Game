class_name CaterpillarEnemySeedTravel
extends ProjectileState

var delta_count: float = 0.0
var direction: Vector3
var movement: Vector3
var collision: KinematicCollision3D

func _init(new_seed: CaterpillarEnemySeed, dir: Vector3) -> void:
	proj = new_seed
	direction = dir

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	proj.face_direction(direction)

func st_physics_process(delta: float) -> void:
	delta_count += delta

	movement = direction * proj.movement_component.move_speed * delta
	collision = proj.move_and_collide(movement)
	if collision:
		var collider: Object = collision.get_collider()
		if collider.get_collision_layer_value(5):
			return state_machine.change_state(&"Explode", {"hit_player": true})
		else:
			return state_machine.change_state(&"Explode")

	if delta_count >= proj.time_to_live:
		return state_machine.change_state(&"Explode")
	
	proj.move_and_slide()

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	pass
