class_name ParalysisEffect
extends AttackEffect

@export var stun_duration: float

func apply_effect(target: CharacterEntity, delta: float = 0.0, delivering_object: AttackObject = null) -> bool:
	if !target.paralyzed:
		print("here")
		target.paralysis_timer = 0.0
		target.paralysis_duration = stun_duration
		target.paralyzed = true
		target.state_machine.change_state(&"Idle")
	else:
		print("already paralyzed")
	
	return true
