class_name PlayerIdle
extends PlayerState

func st_physics_process(delta: float):
	if get_player_movement():
		state_machine.change_state("Walk")
