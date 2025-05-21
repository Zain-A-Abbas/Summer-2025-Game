class_name StateMachine
extends Node

var states: Array[State] = []
var current_state: State

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.state_physics_process(delta)
	
func _process(delta: float) -> void:
	if current_state:
		current_state.state_process(delta)

func assign_states(new_states: Array[State], starting_state: State):
	states = new_states
	if starting_state: # 'if object:' means 'if object is not null'
		current_state = starting_state
	else:
		current_state = new_states[0]

func change_state(new_state: State, args: Dictionary[String, Variant] = {}):
	if current_state:
		current_state.exit_state(new_state, args)
	new_state.enter_state(current_state, args)
