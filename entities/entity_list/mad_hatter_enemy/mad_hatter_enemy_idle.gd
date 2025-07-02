class_name MadHatterEnemyIdle
extends EnemyState
	

func st_physics_process(delta: float) -> void:
	state_machine.change_state(&"Wander")
