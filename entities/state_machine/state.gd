class_name State
extends RefCounted

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	pass

func exit_state(next_state: State, args: Dictionary[String, Variant]):
	pass

func state_process(delta: float) -> void:
	pass

func state_physics_process(delta: float) -> void:
	pass
