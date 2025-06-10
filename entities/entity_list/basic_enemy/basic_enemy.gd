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
