class_name FlowerEnemyBomb
extends CharacterEntity

@onready var atk_obj: AttackObject = %Explosion

func _ready() -> void:
	prepare_states()
	
func prepare_states():
	var bomb_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", FlowerEnemyBombIdle.new(self)),
		StateInitializer.new(&"Wait", FlowerEnemyBombWait.new(self)),
		StateInitializer.new(&"Explode", FlowerEnemyBombExplode.new(self, atk_obj))
	]
	
	state_machine.assign_states(bomb_states)
	entity_animator.hide()
	atk_obj.hitbox.hide()
