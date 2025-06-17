class_name MouseEnemy
extends Enemy

@onready var thrust: Node3D = %basic_attack

func prepare_states():
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", MouseEnemyIdle.new(self)),
		StateInitializer.new(&"Run", MouseEnemyRun.new(self)),
		StateInitializer.new(&"Charge", MouseEnemyCharge.new(self)),
		StateInitializer.new(&"Jump", MouseEnemyJump.new(self)),
		StateInitializer.new(&"Thrust", MouseEnemyThrust.new(self, thrust))
	]
	
	state_machine.assign_states(enemy_states)
