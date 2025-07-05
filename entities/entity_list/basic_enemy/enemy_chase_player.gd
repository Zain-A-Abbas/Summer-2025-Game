class_name EnemyChasePlayer
extends EnemyState

const CHASE_STOP_DISTANCE: float = 2.0
const ATTACK_COOLDOWN: float = 1.0
const RUN_TIME: float = 0.3
const WALK_TIME: float = 0.5

var attack_cooldown_timer: float = 0.0
var is_attack_cooldown: bool = false
var direction_timer: float = 0.0
var direction: Vector3 = Vector3.ZERO
var step_timer: float = 0.0
var step_time: float = 0.0
var step_index: int = 1

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	direction = face_player()
	step_time = RUN_TIME
	
	if args.has("from_attack"):
		is_attack_cooldown = true
		enemy.animation_tree["parameters/WalkRun/blend_position"] = 0.0
		attack_cooldown_timer = 0.0
		step_time = WALK_TIME
	
	step_timer = 0.0
	step_index = 2
	
	enemy.action_animator.play("basic_enemy_animation_library/walk")
	enemy.play_sound_fx(enemy.sounds, &"run_step_1")

func st_physics_process(delta: float) -> void:
	attack_cooldown_timer += delta
	direction_timer += delta
	step_timer += delta
	
	if direction_timer >= 0.05:
		direction = face_player()
		direction_timer = 0.0
	
	if !is_attack_cooldown:
		enemy.animation_tree["parameters/WalkRun/blend_position"] = move_toward(enemy.animation_tree["parameters/WalkRun/blend_position"], 1.0, delta * 4.0)
	
	if attack_cooldown_timer > ATTACK_COOLDOWN && is_attack_cooldown:
		is_attack_cooldown = false
		enemy.animation_tree["parameters/WalkRun/blend_position"] = 0.0
		attack_cooldown_timer = 0.0
		step_time = RUN_TIME
	
	enemy.velocity = direction * enemy.movement_component.move_speed * delta * (1.0 - 0.5 * float(is_attack_cooldown)) # Half speed on cooldown
	enemy.face_direction(direction)
	enemy.move_and_slide()
	
	if distance_to_player() < CHASE_STOP_DISTANCE:
		if !is_attack_cooldown:
			state_machine.change_state(&"BasicAttack")
			return
	
	# play footstep sound fx
	if step_timer > step_time:
		enemy.play_sound_fx(enemy.sounds, "run_step_%d" % step_index)
		step_index += 1
		
		step_timer = 0.0
		if step_index > 5:
			step_index = 1
