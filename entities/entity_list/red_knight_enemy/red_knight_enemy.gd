class_name RedKnightEnemy
extends Enemy

@export var hurtbox: HurtboxComponent
@export var instant_turn_hp_amount: int = 40
@export var player_pushback: float = 200.0
@export var aggro_range: Array[float] = [3.0, 9.0]
@export var active_radius: float = 15.0
@export var swing_move_speed: float = 3000.0
@export var distance_to_swing: float = 7.0

var direction: Vector3

@onready var thrust: AttackObject = %basic_attack
@onready var ray_cast: RayCast3D = %ray_cast


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
		player.velocity = direction * player_pushback
		player.move_and_slide()

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	enemy_killed.emit(self)
	queue_free()
