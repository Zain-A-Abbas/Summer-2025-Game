class_name PlayerDodge
extends PlayerState

var dodge_speed: float = 2000.0
var delta_count: float = 0
var direction: Vector2 = Vector2.ZERO
var movement_vector: Vector3 = Vector3.ZERO
const DODGE_TIME: int = 7 # frames

func st_physics_process(delta: float) -> void:
	if delta_count == 0: # get direction
		
		direction = get_player_movement()
		if direction == Vector2.ZERO:
			direction = Vector2(1, 0).rotated(deg_to_rad(31))
		movement_vector = Vector3(-direction.x, 0, direction.y)
	
	delta_count += delta
	
	if delta_count >= DODGE_TIME * delta:
		delta_count = 0
		state_machine.change_state("Idle")
	else:
		player.velocity = movement_vector * dodge_speed * delta
		player.move_and_slide()
