class_name MouseEnemy
extends Enemy

@onready var thrust: AttackObject = %basic_attack

var jump_positions: Node3D

func prepare_states():
	jump_positions = enemy_data.get_node("JumpPositions")
	
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", MouseEnemyIdle.new(self)),
		StateInitializer.new(&"Run", MouseEnemyRun.new(self)),
		StateInitializer.new(&"Charge", MouseEnemyCharge.new(self)),
		StateInitializer.new(&"Jump", MouseEnemyJump.new(self, jump_positions)),
		StateInitializer.new(&"Thrust", MouseEnemyThrust.new(self, thrust))
	]
	
	state_machine.assign_states(enemy_states)

func _on_hurtbox_hit_received(attack_object: AttackObject) -> void:
	hurt_effect()
	resolve_hit(attack_object)
