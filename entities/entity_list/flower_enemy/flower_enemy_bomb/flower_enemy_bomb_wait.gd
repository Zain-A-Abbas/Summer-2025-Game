class_name FlowerEnemyBombWait
extends ProjectileState

var delta_count: float = 0.0

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0
	proj.entity_animator.show()

func st_physics_process(delta: float) -> void:
	delta_count += delta

	if delta_count >= 1.0:
		state_machine.change_state(&"Explode")
		return

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	pass
