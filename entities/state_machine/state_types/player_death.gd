class_name PlayerDeath
extends PlayerState

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	player.velocity = Vector3.ZERO
	player.action_animator.play("death")

func st_physics_process(delta: float):
	player.velocity = Vector3.ZERO
