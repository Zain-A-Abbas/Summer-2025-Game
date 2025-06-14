class_name PlayerWalk
extends PlayerState

func st_physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		return state_machine.change_state(&"Attack", {"attack_name": &"basic_attack"})
	
	var movement_input: Vector2 = get_player_movement()
	if movement_input == Vector2.ZERO: # if no movement register, go back to idle state
		state_machine.change_state(&"Idle")
		return

	if Input.is_action_just_pressed("dodge"):
		state_machine.change_state(&"Dodge")
		return

	var movement_vector: Vector3 = Vector3(-movement_input.x, 0.0, movement_input.y)

	player.velocity = movement_vector * player.movement_component.move_speed * delta
	player.rotation.y = Vector2(-movement_vector.x, movement_vector.z).angle() + deg_to_rad(90)
	player.move_and_slide()
