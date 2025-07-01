class_name DamageEffect
extends AttackEffect

@export var damage: int = 1

func apply_effect(target: CharacterEntity, delivering_object: AttackObject):
	var final_damage: int = damage
	if delivering_object.entity is Player:
		var player: Player = delivering_object.entity
		final_damage = damage * (1 + player.parry_counter)
		player.parry_counter = 0
	
	target.health_component.lose_health(target.health_component.current_health - final_damage)
	#print("health: ", target.health_component.current_health)
	if target.health_component.current_health == 0:
		target.char_entity_die()
	
	
	if target is Player:
		target.player_damage_taken.emit(target, final_damage)
	if target is Enemy:
		target.enemy_damage_taken.emit(target, final_damage)
