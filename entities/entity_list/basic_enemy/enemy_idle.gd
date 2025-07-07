class_name EnemyIdle
extends EnemyState


func st_physics_process(delta: float) -> void:
	state_machine.change_state(&"Wander")
