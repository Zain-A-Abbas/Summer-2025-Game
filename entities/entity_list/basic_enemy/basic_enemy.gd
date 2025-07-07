class_name BasicEnemy
extends Enemy

@export var close_to_player_distance: float = 7.0
@export var chase_stop_distance: float = 2.0
@export var attack_cooldown: float = 1.0
@export var wander_duration: float = 6.0
@export var change_direction_timestamp: float = 1.5

@onready var basic_attack: Node3D = %basic_attack
@onready var ray_cast: Node3D = %ray_cast

func prepare_states():
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", EnemyIdle.new(self)),
		StateInitializer.new(&"Chase", EnemyChasePlayer.new(self, ray_cast)),
		StateInitializer.new(&"BasicAttack", EnemyBasicAttack.new(self, basic_attack)),
		StateInitializer.new(&"Wander", EnemyWander.new(self, ray_cast))
	]
	
	state_machine.assign_states(enemy_states)

func _on_hurtbox_hit_received(attack_object: AttackObject, invin: bool) -> void:
	if !invin:
		play_sound_fx(sounds, &"damaged")
		hurt_effect()
		resolve_hit(attack_object)

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	enemy_killed.emit(self)
	queue_free()
