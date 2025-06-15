class_name FlowerEnemyBomb
extends CharacterEntity

func _ready() -> void:
	prepare_states()
	
func prepare_states():
	var bomb_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", FlowerEnemyBombIdle.new(self)),
		StateInitializer.new(&"Midair", FlowerEnemyBombMidair.new(self)),
		StateInitializer.new(&"Explode", FlowerEnemyBombExplode.new(self))
	]
	
	state_machine.assign_states(bomb_states)
