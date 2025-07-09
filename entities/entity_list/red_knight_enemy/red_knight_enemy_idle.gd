class_name RedKnightEnemyIdle
extends EnemyState

func st_physics_process(delta: float) -> void:
	if enemy.paralysis_effect(delta):
		return

	if distance_to_player() <= enemy.active_radius:
		return state_machine.change_state(&"Block")
