class_name PlayerIdle
extends PlayerState

func st_physics_process(delta: float):
	if Input.is_action_just_pressed("attack"):
		return state_machine.change_state(&"Attack", {"attack_name": &"basic_attack"})
	
	if Input.is_action_just_pressed("dodge"):
		return state_machine.change_state(&"Dodge")
	if get_player_movement():
		return state_machine.change_state(&"Walk")
