class_name FlowerEnemyBombIdle
extends ProjectileState

func st_physics_process(delta: float) -> void:
	state_machine.change_state(&"Wait")
