class_name FlowerEnemyBombIdle
extends ProjectileState

var bomb: FlowerEnemyBomb
var exploded: bool = false

func _init(new: FlowerEnemyBomb) -> void:
	bomb = new

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	if args.has("exploded"):
		exploded = true

func st_physics_process(delta: float) -> void:
	if exploded:
		bomb.char_entity_die()
	else:
		state_machine.change_state(&"Wait")
