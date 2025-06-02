class_name PlayerWalk
extends PlayerState

const MOVE_SPEED: float = 550.0

func st_physics_process(delta: float) -> void:
	var movement_input: Vector2 = get_player_movement()
	if movement_input == Vector2.ZERO: # if no movement register, go back to idle state
		state_machine.change_state("Idle")
		return

	if Input.is_action_just_released("dodge"):
		print("Dodging")
		state_machine.change_state("Dodge")
		return

	var movement_vector: Vector3 = Vector3(-movement_input.x, 0.0, movement_input.y)

	player.velocity = movement_vector * MOVE_SPEED * delta
	player.move_and_slide()
