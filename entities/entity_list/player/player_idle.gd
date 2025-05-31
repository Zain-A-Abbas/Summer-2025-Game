class_name PlayerIdle
extends PlayerState

func st_physics_process(delta: float):
	if get_player_movement():
		if Input.is_action_just_pressed("dodge"):
			state_machine.change_state("Dodge")
		else:
			state_machine.change_state("Walk")
