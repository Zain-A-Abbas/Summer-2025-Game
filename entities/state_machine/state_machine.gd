class_name StateMachine
extends Node

## A state machine class that stores all the states for an entity, 
## tracks the current state, and runs process functions on the current state.

var states: Array[State] = [] 
## Dictionary used to switch between the states. StringName is preferred over
## String as StringNames are faster for comparisons, leading to faster
## dictionary lookups.
var state_map: Dictionary[StringName, State] = {}

var current_state: State = null

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.st_physics_process(delta)
	
func _process(delta: float) -> void:
	if current_state:
		current_state.st_process(delta)

func assign_states(state_initializers: Array[StateInitializer], starting_state: State = null):
	for initializer in state_initializers:
		states.append(initializer.state)
		state_map[initializer.state_name] = initializer.state
	
	for state in states:
		state.state_machine = self
	
	if !starting_state: # 'if object:' means 'if object is not null'
		starting_state = states[0]
	#current_state = starting_state
	
	change_state_process(starting_state)

func change_state_process(new_state: State, args: Dictionary[String, Variant] = {}):
	var previous_state: State = null
	if current_state:
		previous_state = current_state
		previous_state.exit_state(new_state, args)
	current_state = new_state
	new_state.enter_state(previous_state, args)

func change_state(change_state_name: String, args: Dictionary[String, Variant] = {}):
	change_state_process(state_map[change_state_name], args)
