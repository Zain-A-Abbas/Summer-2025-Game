class_name MouseEnemyRun
extends EnemyState

const MIN_TIME_TO_RUN: float = 0.4
const TIME_TO_JUMP: float = 1.3
const MIN_SPEED: float = 100
const STEP_TIME: float = 0.3

var delta_count: float = 0.0
var step_timer: float = 0.0

var direction: Vector3 = Vector3.ZERO
var distance_to_run: float = 0.0
var move_speed: float
var step_index = 1

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	step_timer = 0.0
	step_index = 2
	
	if args.has("DISTANCE_TO_RUN"):
		distance_to_run = args["DISTANCE_TO_RUN"]
	move_speed = enemy.movement_component.move_speed
	enemy.action_animator.play("basic_enemy_animation_library/walk")
	enemy.animation_tree["parameters/WalkRun/blend_position"] = 100.0
	
	enemy.play_sound_fx(enemy.sounds, "crawl_1")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	step_timer += delta

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
	enemy.face_direction(direction)
	enemy.move_and_slide()

	# play footstep sound fx
	if step_timer > STEP_TIME:
		enemy.play_sound_fx(enemy.sounds, "crawl_%d" % step_index)
		step_index += 1
		
		step_timer = 0.0
		if step_index > 3:
			step_index = 1
