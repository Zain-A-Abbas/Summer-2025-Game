class_name BurnEffect
extends AttackEffect

@export var duration: float = 0.0

func apply_effect(target: CharacterEntity, delivering_object: AttackObject):
	if !target.attack_effects_applied["Burning"]["active"]:
		target.attack_effects_applied["Burning"]["active"] = 1
		target.attack_effects_applied["Burning"]["duration"] = duration
