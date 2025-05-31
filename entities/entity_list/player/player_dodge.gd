class_name PlayerDodge
extends PlayerState

var dodge_speed: float = 500.0

func st_physics_process(delta: float) -> void:
	var movement_input: Vector2 = get_player_movement()
	var movement_vector: Vector3 = Vector3(-movement_input.x, 0.0, movement_input.y)
	
	player.velocity = movement_vector * dodge_speed * delta
	player.move_and_slide()
