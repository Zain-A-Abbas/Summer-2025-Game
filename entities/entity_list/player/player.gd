class_name Player
extends CharacterEntity

func _ready() -> void:
	prepare_states()

func prepare_states():
	# The & before string declarations marks it as a StringName, which is a
	# separate class that is much faster for string comparisons.
	var player_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", PlayerIdle.new(self)),
		StateInitializer.new(&"Walk", PlayerWalk.new(self)),
	]
	
	state_machine.assign_states(player_states)
