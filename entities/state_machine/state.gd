class_name State
extends RefCounted
 
var state_machine: StateMachine

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	pass

func exit_state(next_state: State, args: Dictionary[String, Variant]):
	pass

func st_process(delta: float) -> void:
	pass

func st_physics_process(delta: float) -> void:
	pass
