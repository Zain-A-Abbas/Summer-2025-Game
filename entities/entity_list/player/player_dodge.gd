class_name PlayerDodge
extends PlayerState

var dodge_speed: float = 1000.0
var delta_count: float = 0
var direction: Vector2 = Vector2.ZERO
const DODGE_TIME: float = 0.5

func st_physics_process(delta: float) -> void:
	delta_count += delta
	if delta_count >= DODGE_TIME:
		delta_count = 0
		state_machine.change_state("Idle")
	else:
		direction = get_player_movement()
		if direction == Vector2.ZERO:
			direction = Vector2(1, 0).rotated(deg_to_rad(31))
		
		var movement_vector = Vector3(-direction.x, 0, direction.y)
		player.velocity = movement_vector * dodge_speed * delta
		player.move_and_slide()
		
		
		
		
