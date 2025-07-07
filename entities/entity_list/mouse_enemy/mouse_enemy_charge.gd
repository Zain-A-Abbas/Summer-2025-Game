class_name MouseEnemyCharge
extends EnemyState

var indicator_shown: bool = false
var delta_count: float = 0
var direction: Vector3 = Vector3.ZERO


func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	indicator_shown = false
	enemy.action_animator.play("mouse/charge")

func st_physics_process(delta: float) -> void:
	delta_count += delta

	enemy.face_direction(face_player())

	# atk indicator
	if delta_count >= enemy.charge_duration * 0.5 && !indicator_shown:
		enemy.attack_indicator_animator.play("show_indicator")
		indicator_shown = true

	if delta_count > enemy.minimum_charge_time && (distance_to_player() < enemy.active_range[0] || distance_to_player() >= enemy.active_range[1]):
		return state_machine.change_state(&"Run")
 
	if delta_count >= enemy.charge_duration:
		return state_machine.change_state(&"Pounce")
		
func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	if indicator_shown:
		enemy.attack_indicator_animator.play("hide_indicator")
