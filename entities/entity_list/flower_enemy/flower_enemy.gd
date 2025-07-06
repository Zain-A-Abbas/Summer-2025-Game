class_name FlowerEnemy
extends Enemy

@export var hurtbox: HurtboxComponent

var dig_positions: Node3D

func prepare_states():
	dig_positions = enemy_data.get_node("DigPositions")
	
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", FlowerEnemyIdle.new(self)),
		StateInitializer.new(&"Dig", FlowerEnemyDig.new(self, dig_positions)),
		StateInitializer.new(&"Shoot", FlowerEnemyShoot.new(self))
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
