class_name FlowerEnemyBomb
extends CharacterEntity

@onready var atk_obj: AttackObject = %Explosion
@onready var bomb: CSGSphere3D = %placeholder_model # NOTE: temporary visual effect

func _ready() -> void:
	set_process(false)
	
func initialize_bomb() -> void:
	prepare_states()

func start_bomb() -> void:
	set_process(true)

func prepare_states():
	var bomb_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", FlowerEnemyBombIdle.new(self)),
		StateInitializer.new(&"Wait", FlowerEnemyBombWait.new(bomb)),
		StateInitializer.new(&"Explode", FlowerEnemyBombExplode.new(self, bomb, atk_obj))
	]
	
	state_machine.assign_states(bomb_states)
	bomb.hide()
	atk_obj.hitbox.hide()

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	queue_free()
