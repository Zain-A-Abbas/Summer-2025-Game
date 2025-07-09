class_name AttackEffectManager
extends Node

const BURN_TIME: float = 0.35
const BURN_DAMAGE: int = 2

@export var recipient: CharacterEntity

var burn_duration_timer: float = 0.0
var burn_timer: float = 0.0


func burn_effect(delta: float):
	burn_timer += delta
	burn_duration_timer += delta
	
	if burn_timer > BURN_TIME:
		recipient.health_component.lose_health(recipient.health_component.current_health - BURN_DAMAGE)
		if recipient is Player:
			recipient.player_damage_taken.emit(recipient, BURN_DAMAGE)
		if recipient is Enemy:
			recipient.enemy_damage_taken.emit(recipient, BURN_DAMAGE)
		
		burn_timer = 0.0
	
	if burn_duration_timer > recipient.attack_effects_applied["Burning"]["duration"]:
		burn_duration_timer = 0.0
		burn_timer = 0.0
		recipient.attack_effects_applied["Burning"]["active"] = false
