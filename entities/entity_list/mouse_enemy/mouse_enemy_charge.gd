class_name MouseEnemyCharge
extends EnemyState

const CHARGE_TIME: float = 1.0

var indicator_shown: bool = false
var delta_count: float = 0
var direction: Vector3 = Vector3.ZERO
var distance_to_run: float = 0

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	indicator_shown = false
	if args.has("DISTANCE_TO_RUN"):
		distance_to_run = args["DISTANCE_TO_RUN"]
	enemy.action_animator.play("basic_enemy_animation_library/RESET")

func st_physics_process(delta: float) -> void:
	delta_count += delta

	direction = face_player()
	enemy.rotation.y = get_angle_to_face_player(direction)

	if delta_count >= CHARGE_TIME * 0.5 && !indicator_shown:
		indicator_shown = true
		enemy.attack_indicator_animator.play("show_indicator")

	if distance_to_player() < distance_to_run:
		state_machine.change_state(&"Run", {"DISTANCE_TO_RUN" = distance_to_run})
		if indicator_shown:
			enemy.attack_indicator_animator.play("hide_indicator")
		return
 
	if delta_count >= CHARGE_TIME:
		state_machine.change_state(&"Thrust", {"direction" = direction})
		return
