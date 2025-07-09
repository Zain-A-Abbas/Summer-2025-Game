class_name MouseEnemyIdle
extends EnemyState

var from_pounce: bool = false
var delta_count: float = 0.0


func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	from_pounce = args.has("from_pounce")
	enemy.action_animator.play("mouse/idle") 

func st_physics_process(delta: float) -> void:
	# pounce cooldown
	if from_pounce:
		delta_count += delta
		if delta_count <= enemy.pounce_cooldown:
			return
		else:
			from_pounce = false
	
	if enemy.paralysis_effect(delta):
		return
	
	if distance_to_player() < enemy.active_range[0]:
		return state_machine.change_state(&"Run")
	elif distance_to_player() < enemy.active_range[1]:
		return state_machine.change_state(&"Charge")
