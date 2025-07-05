class_name FlowerEnemyBombWait
extends ProjectileState

const TTL: float = 1.1

var delta_count: float = 0.0
var bomb: CSGSphere3D

func _init(new: CSGSphere3D) -> void:
	bomb = new

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	bomb.show()

func st_physics_process(delta: float) -> void:
	delta_count += delta

	if delta_count >= TTL:
		return state_machine.change_state(&"Explode")

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	pass
