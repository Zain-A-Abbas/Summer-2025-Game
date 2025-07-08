class_name BurnEffect
extends AttackEffect

const BURN_TIME: float = 0.4

@export var duration: float = 0.0
@export var dmg_over_time: int = 1

var duration_timer: float = 0.0
var burn_timer: float = 0.0

func apply_effect(target: CharacterEntity, delivering_object: AttackObject):
	if !target.attack_effects_applied["Burning"]["active"]:
		target.attack_effects_applied["Burning"]["active"] = 1
		target.attack_effects_applied["Burning"]["duration"] = duration
		target.attack_effects_applied["Burning"]["dmg_over_time"] = dmg_over_time
		burn_timer = 0.0
		duration_timer = 0.
