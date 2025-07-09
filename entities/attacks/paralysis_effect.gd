class_name ParalysisEffect
extends AttackEffect

@export var stun_duration: float
@export var stun_chance: float ## Chance to trigger effect

func _init(duration: float, chance: float):
	stun_duration = duration
	stun_chance = chance

func apply_effect(target: CharacterEntity, delta: float = 0.0, delivering_object: AttackObject = null) -> bool:
	var roll: float = randf_range(0, 100.0)
	
	if roll <= stun_chance && !target.paralyzed:
		target.paralysis_timer = 0.0
		target.paralysis_duration = stun_duration
		target.paralyzed = true
		target.state_machine.change_state(&"Idle")
	#else:
	#	print("failed to paralyze"))
	
	return true
