class_name EnemyIdle
extends EnemyState

func st_physics_process(delta: float) -> void:
	if enemy.paralysis_effect(delta):
		return
	
	enemy.velocity = enemy.gravity_velocity() * delta
	enemy.move_and_slide()
	
	state_machine.change_state(&"Wander")
