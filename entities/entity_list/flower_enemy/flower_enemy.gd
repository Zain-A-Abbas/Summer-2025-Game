class_name FlowerEnemy
extends Enemy

@onready var attack: Node3D = %Attacks
@onready var model: Node3D = %placeholder_model

func prepare_states():
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", FlowerEnemyIdle.new(self)),
		StateInitializer.new(&"Dig", FlowerEnemyDig.new(self, model)),
		StateInitializer.new(&"Shoot", FlowerEnemyShoot.new(self, attack, model))
	]
	
	state_machine.assign_states(enemy_states)
