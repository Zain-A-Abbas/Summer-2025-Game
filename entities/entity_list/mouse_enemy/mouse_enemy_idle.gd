class_name MouseEnemyIdle
extends EnemyState

var from_pounce: bool = false
var delta_count: float = 0.0


func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	from_pounce = args.has("from_pounce")
	enemy.action_animator.play("mouse/idle") 

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	# pounce cooldown
	if from_pounce:
		if delta_count <= enemy.pounce_cooldown:
			return
		else:
			from_pounce = false
		
	if distance_to_player() < enemy.DEAGGRO_DISTANCE:
		return state_machine.change_state(&"Run")
	else:
		return state_machine.change_state(&"Charge")
