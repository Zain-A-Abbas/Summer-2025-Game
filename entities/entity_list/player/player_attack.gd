class_name PlayerAttack
extends PlayerState

var delta_count: float = 0.0
var animation_time: float = 0.0

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	var attack_name: StringName = args["attack_name"]
	player.animation_effects.play(attack_name)
	player.action_parameters.play(attack_name)
	animation_time = player.action_parameters.get_animation(attack_name).length
	
	delta_count = 0.0


func st_physics_process(delta: float) -> void:
	delta_count += delta
	if delta_count > animation_time:
		state_machine.change_state(&"Idle")
