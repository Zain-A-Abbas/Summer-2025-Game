class_name AttackEffect
extends Resource

enum AttackEffectType {
	DAMAGE,
	BURN,
	PARALYSIS
}

var effect_type: AttackEffectType

func initialize_effect(args: Dictionary[String, Variant]):
	pass

func apply_effect(target: CharacterEntity, delta: float = 0.0, delivering_object: AttackObject = null) -> bool:
	return true
