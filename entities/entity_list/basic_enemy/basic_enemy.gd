class_name BasicEnemy
extends Enemy

@onready var basic_attack: Node3D = %basic_attack

func prepare_states():
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", EnemyIdle.new(self)),
		StateInitializer.new(&"Chase", EnemyChasePlayer.new(self)),
		StateInitializer.new(&"BasicAttack", EnemyBasicAttack.new(self, basic_attack)),
		StateInitializer.new(&"Wait", EnemyWait.new(self))
	]
	
	state_machine.assign_states(enemy_states, enemy_states[1].state)

func _on_hurtbox_hit_received(attack_object: AttackObject, invin: bool) -> void:
	if !invin:
		play_sound_fx(sounds, &"damaged")
		hurt_effect()
		resolve_hit(attack_object)

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	enemy_killed.emit(self)
	queue_free()
