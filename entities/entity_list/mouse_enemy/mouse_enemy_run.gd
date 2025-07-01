class_name MouseEnemyRun
extends EnemyState

const MIN_TIME_TO_RUN: float = 0.4
const TIME_TO_JUMP: float = 1.3
const MIN_SPEED: float = 100

var delta_count: float = 0
var direction: Vector3 = Vector3.ZERO
var distance_to_run: float = 0
var move_speed: float

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	if args.has("DISTANCE_TO_RUN"):
		distance_to_run = args["DISTANCE_TO_RUN"]
	move_speed = enemy.movement_component.move_speed
	enemy.action_animator.play("basic_enemy_animation_library/walk")
	enemy.animation_tree["parameters/WalkRun/blend_position"] = 100.0

func st_physics_process(delta: float) -> void:
	delta_count += delta

	if delta_count >= TIME_TO_JUMP:
		enemy.action_animator.play("basic_enemy_animation_library/RESET")
		state_machine.change_state(&"Jump")
		return

	if delta_count < TIME_TO_JUMP && delta_count >= MIN_TIME_TO_RUN && distance_to_player() >= distance_to_run:
		state_machine.change_state(&"Idle")
		return

	direction = face_player().rotated(Vector3(0,1,0), deg_to_rad(180))
	if move_speed >= MIN_SPEED:
		move_speed -= 2.0
		enemy.animation_tree["parameters/WalkRun/blend_position"] = move_toward(enemy.animation_tree["parameters/WalkRun/blend_position"], 0, delta * 4.0)

	enemy.velocity = direction * move_speed * delta
	enemy.rotation.y = get_angle_to_face_player(direction)
	enemy.move_and_slide()
