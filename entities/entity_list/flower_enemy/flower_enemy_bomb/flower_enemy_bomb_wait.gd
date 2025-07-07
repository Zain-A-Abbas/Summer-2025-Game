class_name FlowerEnemyBombWait
extends ProjectileState

var delta_count: float = 0.0
var bomb: CSGSphere3D # temporary


func _init(new: FlowerEnemyBomb, model: CSGSphere3D) -> void:
	proj = new
	bomb = model

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	bomb.show()

func st_physics_process(delta: float) -> void:
	delta_count += delta

	if delta_count >= proj.time_to_live:
		return state_machine.change_state(&"Explode")
