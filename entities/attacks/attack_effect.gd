class_name AttackEffect
extends Resource

var user: CharacterEntity

func apply_effect(target: CharacterEntity, delta: float = 0.0, delivering_object: AttackObject = null) -> bool:
	return true
