class_name RedKnightEnemyIdle
extends EnemyState

var from_swing: bool = false
var delta_count: float = 0.0


func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	from_swing = args.has("from_swing")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	# swing cooldown
	if from_swing:
		if delta_count <= enemy.swing_cooldown:
			return
		else:
			from_swing = false
			
	if distance_to_player() <= enemy.active_radius:
		return state_machine.change_state(&"Block")
