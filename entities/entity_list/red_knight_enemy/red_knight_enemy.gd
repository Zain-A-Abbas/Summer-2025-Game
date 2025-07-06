class_name RedKnightEnemy
extends Enemy

const PLAYER_PUSHBACK: float = 200.0

@onready var thrust: AttackObject = %basic_attack
@onready var ray_cast: RayCast3D = %ray_cast

@export var hurtbox: HurtboxComponent

var direction: Vector3

func prepare_states():	
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", RedKnightEnemyIdle.new(self)),
		StateInitializer.new(&"Block", RedKnightEnemyBlock.new(self, hurtbox, ray_cast)),
		StateInitializer.new(&"Swing", RedKnightEnemySwing.new(self, thrust))
	]
	
	state_machine.assign_states(enemy_states)

func _on_hurtbox_hit_received(attack_object: AttackObject, invin: bool) -> void:
	if !invin:
		play_sound_fx(sounds, &"damaged")
		hurt_effect()
		resolve_hit(attack_object)
	else:
		play_sound_fx(sounds, &"shield_block")
		player.velocity = direction * PLAYER_PUSHBACK
		player.move_and_slide()

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	enemy_killed.emit(self)
	queue_free()
