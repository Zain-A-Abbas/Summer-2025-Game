class_name MadHatterEnemy
extends Enemy

var hatter_path: Node3D

func prepare_states():
	hatter_path = enemy_data.get_node("HatterPath")
	
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", MadHatterEnemyIdle.new(self)),
		StateInitializer.new(&"Wander", MadHatterEnemyWander.new(self, hatter_path)),
		StateInitializer.new(&"Summon", MadHatterEnemySummon.new(self))
	]
	
	state_machine.assign_states(enemy_states)

func _on_hurtbox_hit_received(attack_object: AttackObject) -> void:
	hurt_effect()
	resolve_hit(attack_object)
