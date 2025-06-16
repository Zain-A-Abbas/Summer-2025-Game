class_name FlowerEnemy
extends Enemy

var direction: Vector3 = Vector3.ZERO

@onready var bomb: FlowerEnemyBomb = %FlowerEnemyBomb
@onready var attacks: Node3D = %Attacks

func prepare_states():
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", FlowerEnemyIdle.new(self)),
		StateInitializer.new(&"Dig", FlowerEnemyDig.new(self)),
		StateInitializer.new(&"Shoot", FlowerEnemyShoot.new(self, bomb, attacks))
	]
	
	state_machine.assign_states(enemy_states)
