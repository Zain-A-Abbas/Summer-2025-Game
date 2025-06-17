class_name MouseEnemyIdle
extends EnemyState

const DISTANCE_TO_RUN: float = 5.0

func st_physics_process(delta: float) -> void:
	if distance_to_player() < DISTANCE_TO_RUN:
		state_machine.change_state(&"Run", {"DISTANCE_TO_RUN" = DISTANCE_TO_RUN})
	else:
		state_machine.change_state(&"Charge")
