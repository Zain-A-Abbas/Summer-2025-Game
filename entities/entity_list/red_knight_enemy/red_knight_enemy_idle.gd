class_name RedKnightEnemyIdle
extends EnemyState

const SWING_COOLDOWN: float = 1.0

var from_swing: bool = false
var delta_count: float = 0.0
	
func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	if args.has("from_swing"):
		from_swing = args["from_swing"]
	else:
		from_swing = false

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	# swing cooldown
	if from_swing:
		if delta_count <= SWING_COOLDOWN:
			return
		else:
			from_swing = false
	
	state_machine.change_state(&"Block")
