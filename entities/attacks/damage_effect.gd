class_name DamageEffect
extends AttackEffect

@export var damage: int = 1

func apply_effect(target: CharacterEntity):
	target.health_component.lose_health(target.health_component.current_health - damage)
	#print("health: ", target.health_component.current_health)
	if target.health_component.current_health == 0:
		target.char_entity_die()
	
	if target is Player:
		target.player_damage_taken.emit(target, damage)
	if target is Enemy:
		target.enemy_damage_taken.emit(target, damage)
