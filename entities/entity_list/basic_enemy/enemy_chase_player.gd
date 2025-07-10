class_name EnemyChasePlayer
extends EnemyState

const RUN_TIME: float = 0.3
const WALK_TIME: float = 0.5

var attack_cooldown_timer: float = 0.0
var is_attack_cooldown: bool = false
var direction_timer: float = 0.0
var direction: Vector3 = Vector3.ZERO

var ray_cast: RayCast3D
var step_timer: float = 0.0
var step_time: float = 0.0
var step_index: int = 1


func _init(new_enemy: Enemy, ray: RayCast3D) -> void:
	enemy = new_enemy
	ray_cast = ray

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	attack_cooldown_timer = 0.0
	direction_timer = 0.0
	step_timer = 0.0
	step_index = 2
	
	direction = face_player()
	step_time = RUN_TIME
	
	if args.has("from_attack"):
		is_attack_cooldown = true
		enemy.animation_tree["parameters/WalkRun/blend_position"] = 0.0
		attack_cooldown_timer = 0.0
		step_time = WALK_TIME
	
	enemy.action_animator.play("basic_enemy_animation_library/walk")
	enemy.play_sound_fx(&"run_step_1")

func st_physics_process(delta: float) -> void:
	attack_cooldown_timer += delta
	direction_timer += delta
	step_timer += delta
	
	if !is_attack_cooldown:
		enemy.animation_tree["parameters/WalkRun/blend_position"] = move_toward(enemy.animation_tree["parameters/WalkRun/blend_position"], 1.0, delta * 4.0)
	
	if attack_cooldown_timer > enemy.attack_cooldown && is_attack_cooldown:
		is_attack_cooldown = false
		enemy.animation_tree["parameters/WalkRun/blend_position"] = 0.0
		attack_cooldown_timer = 0.0
		step_time = RUN_TIME
	
	# change direction
	if direction_timer >= 0.05:
		# if enemy can see player but is too far away
		if ray_cast.is_colliding() && distance_to_player() > enemy.active_radius:
			var collider: Object = ray_cast.get_collider()
			if collider.get_collision_layer_value(5):
				direction = face_player()
			else:
				return state_machine.change_state(&"Wander")
		elif distance_to_player() <= enemy.active_radius: # player is close enough, no ray cast checks
			direction = face_player()
		else:
			return state_machine.change_state(&"Wander")
		direction_timer = 0.0
	
	enemy.velocity = direction * enemy.movement_component.move_speed * delta * (1.0 - 0.5 * float(is_attack_cooldown)) # Half speed on cooldown
	enemy.face_direction(direction)
	enemy.move_and_slide()
	
	if distance_to_player() < enemy.chase_stop_distance:
		if !is_attack_cooldown:
			return state_machine.change_state(&"BasicAttack")
	
	# play footstep sound fx
	if step_timer > step_time:
		enemy.play_sound_fx("run_step_%d" % step_index)
		step_index += 1
		
		step_timer = 0.0
		if step_index > 4:
			step_index = 1
