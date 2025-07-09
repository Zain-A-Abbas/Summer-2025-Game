class_name FlowerEnemyBomb
extends CharacterEntity

@export var time_to_live: float = 1.1
@export var explosion_duration: float = 0.85

@onready var atk_obj: AttackObject = %Explosion
@onready var model: CSGSphere3D = %placeholder_model # NOTE: temporary visual effect

func initialize_bomb() -> void:
	prepare_states()

func prepare_states():
	var bomb_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", FlowerEnemyBombIdle.new(self)),
		StateInitializer.new(&"Wait", FlowerEnemyBombWait.new(self, model)),
		StateInitializer.new(&"Explode", FlowerEnemyBombExplode.new(self, model, atk_obj))
	]
	
	state_machine.assign_states(bomb_states)
	model.hide()
	atk_obj.hide()

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	queue_free()
