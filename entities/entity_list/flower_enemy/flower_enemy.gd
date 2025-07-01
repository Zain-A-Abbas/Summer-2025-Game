class_name FlowerEnemy
extends Enemy

var dig_positions: Node3D

func prepare_states():
	dig_positions = enemy_data.get_node("DigPositions")
	
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", FlowerEnemyIdle.new(self)),
		StateInitializer.new(&"Dig", FlowerEnemyDig.new(self, dig_positions)),
		StateInitializer.new(&"Shoot", FlowerEnemyShoot.new(self))
	]
	
	state_machine.assign_states(enemy_states)

func _on_hurtbox_hit_received(attack_object: AttackObject) -> void:
	hurt_effect()
	resolve_hit(attack_object)
