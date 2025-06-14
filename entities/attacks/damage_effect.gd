class_name DamageEffect
extends AttackEffect

@export var damage: int = 1

func apply_effect(target: CharacterEntity):
	target.health_component.lose_health(target.health_component.current_health - damage)
	print(target.health_component.current_health)
	if target.health_component.current_health == 0:
		target.char_entity_die()
