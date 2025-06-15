class_name FlowerEnemy
extends Enemy

var direction: Vector3 = Vector3.ZERO

@onready var atk_obj: AttackObject = %BombData
@onready var bomb: FlowerEnemyBomb = %FlowerEnemyBomb

func prepare_states():
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", FlowerEnemyIdle.new(self)),
		StateInitializer.new(&"Dig", FlowerEnemyDig.new(self)),
		StateInitializer.new(&"Shoot", FlowerEnemyShoot.new(self, bomb, atk_obj))
	]
	
	state_machine.assign_states(enemy_states)
	bomb.hide()
