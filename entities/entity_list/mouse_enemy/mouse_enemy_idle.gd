class_name MouseEnemyIdle
extends EnemyState

const DISTANCE_TO_RUN: float = 7.0
const THRUST_COOLDOWN: float = 1.0

var from_thrust: bool = false
var delta_count: float = 0.0

func _init(new_enemy: Enemy) -> void:
	enemy = new_enemy
	
func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	from_thrust = args.has("from_thrust")
	enemy.action_animator.play("mouse/idle") 

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	# thrust cooldown
	if from_thrust:
		if delta_count <= THRUST_COOLDOWN:
			return
		else:
			from_thrust = false
		
	if distance_to_player() < DISTANCE_TO_RUN:
		state_machine.change_state(&"Run", {"DISTANCE_TO_RUN" = DISTANCE_TO_RUN})
	else:
		state_machine.change_state(&"Charge", {"DISTANCE_TO_RUN" = DISTANCE_TO_RUN})
