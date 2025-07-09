class_name MadHatterEnemyIdle
extends EnemyState


func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	enemy.action_animator.play("mad_hatter_animations/idle")

func st_physics_process(delta: float) -> void:
	if enemy.paralysis_effect(delta):
		return
	
	state_machine.change_state(&"Wander")
