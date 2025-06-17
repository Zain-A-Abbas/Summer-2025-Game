class_name EnemyIdle
extends EnemyState


func st_physics_process(delta: float) -> void:
	if enemy.player:
		state_machine.change_state(&"Chase")
