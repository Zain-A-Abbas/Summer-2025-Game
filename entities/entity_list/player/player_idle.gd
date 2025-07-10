class_name PlayerIdle
extends PlayerState

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	player.action_animator.play("idle")

func st_physics_process(delta: float):
	if player.paralysis_effect(delta):
		return

	if Input.is_action_just_pressed("attack"):
		return state_machine.change_state(&"Attack")
	
	if Input.is_action_just_pressed("dodge") && player.can_dodge():
		return state_machine.change_state(&"Parry")
	if get_player_movement():
		return state_machine.change_state(&"Walk")
	
	player.velocity = player.gravity_velocity() + player.deflect_velocity
	player.velocity *= delta
	player.move_and_slide()
