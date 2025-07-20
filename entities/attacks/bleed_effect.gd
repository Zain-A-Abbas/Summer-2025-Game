class_name BleedEffect
extends AttackEffect

const BLEED_DAMAGE_PERCENTAGE: float = 0.25

func _init():
	effect_type = AttackEffectType.BLEED

func apply_effect(target: CharacterEntity, delta: float = 0.0, delivering_object: AttackObject = null) -> bool:
	if target.inflicted_attack_effect_count[AttackEffectType.BLEED] == target.inflicted_attack_effect_limits[AttackEffectType.BLEED]:
		var damage: int = ceilf(float(target.health_component.max_health) * BLEED_DAMAGE_PERCENTAGE)
		
		target.health_component.lose_health(target.health_component.current_health - damage)
		if target is Player:
			target.bleed_particles.emitting = true
		
		target.inflicted_attack_effect_count[AttackEffectType.BLEED] = 0
	
	return true
