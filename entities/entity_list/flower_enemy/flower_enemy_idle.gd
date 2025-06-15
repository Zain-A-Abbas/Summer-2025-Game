class_name FlowerEnemyIdle
extends EnemyState

const DISTANCE_TO_DIG: float = 4.0

func st_physics_process(delta: float) -> void:
	if distance_to_player() < DISTANCE_TO_DIG:
		state_machine.change_state(&"Dig")
	else:
		state_machine.change_state(&"Shoot")
