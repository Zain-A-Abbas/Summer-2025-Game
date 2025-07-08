class_name ParalysisEffect
extends AttackEffect

@export var duration_per_stun: float = 0.0
@export var number_of_stuns: int = 1

func apply_effect(target: CharacterEntity, delivering_object: AttackObject):
	if !target.attack_effects_applied["Paralysis"]["active"]:
		target.attack_effects_applied["Paralysis"]["active"] = 1
		target.attack_effects_applied["Paralysis"]["duration_per_stun"] = duration_per_stun
		target.attack_effects_applied["Paralysis"]["number_of_stuns"] = number_of_stuns
