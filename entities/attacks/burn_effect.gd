class_name BurnEffect
extends AttackEffect

const BURN_TIME: float = 0.4
const BURN_DAMAGE: int = 2

@export var duration: float = 0.0

var burn_duration_timer: float = 0.0
var burn_timer: float = 0.0

func _init():
	effect_type = AttackEffectType.BURN

func initialize_effect(args: Dictionary[String, Variant]):
	if args.has("duration"):
		duration = args["duration"]

func apply_effect(target: CharacterEntity, delta: float = 0.0, delivering_object: AttackObject = null) -> bool:
	burn_timer += delta
	burn_duration_timer += delta
	
	if burn_timer > BURN_TIME:
		target.health_component.lose_health(target.health_component.current_health - BURN_DAMAGE)
		if target is Player:
			target.player_damage_taken.emit(target, BURN_DAMAGE)
		elif target is Enemy:
			target.enemy_damage_taken.emit(target, BURN_DAMAGE)
		
		burn_timer = 0.0
	
	if burn_duration_timer > duration:
		burn_duration_timer = 0.0
		burn_timer = 0.0
		return true
	
	return false
