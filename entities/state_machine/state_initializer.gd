class_name StateInitializer
extends RefCounted

## An interface used to initialize a state in a state machine. The name is
## used for state lookup when switching states.


var state_name: StringName
var state: State

func _init(st_name: String, st_instance: State) -> void:
	state_name = st_name
	state = st_instance
