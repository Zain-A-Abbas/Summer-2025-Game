class_name RedKnightEnemyBlock
extends EnemyState

const TURNAROUND_SPEED: float = deg_to_rad(1.0)
const NEXT_STEP: float = 0.6

var hurtbox: HurtboxComponent
var ray_cast: RayCast3D
var side_vector: Vector3
var forward_direction: Vector3
var direction_to_player: Vector3
var move_direction: Vector3

var block_time: float = 0.0
var instant_turn_hp_threshold: int = 0
var delta_count: float = 0.0
var step_timer: float = 0.0
var step_index: int = 1
var is_aggro: bool = true
var reset_played: bool = false
var walk_played: bool = false


func _init(new_enemy: Enemy, hb: HurtboxComponent, ray: RayCast3D) -> void:
	enemy = new_enemy
	hurtbox = hb
	ray_cast = ray

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	step_timer = 0.0
	step_index = 2
	
	direction_to_player = face_player()
	enemy.face_direction(direction_to_player)

	block_time = randf_range(4.0, 5.5)
	instant_turn_hp_threshold = enemy.health_component.current_health - enemy.instant_turn_hp_amount
	is_aggro = true
	reset_played = false
	
	enemy.play_sound_fx(&"run_step_1")
	enemy.action_animator.play("basic_enemy_animation_library/walk")
	walk_played = true

func st_physics_process(delta: float) -> void:
	if distance_to_player() > enemy.active_radius:
		return state_machine.change_state(&"Idle")
	
	delta_count += delta
	step_timer += delta
	
	enemy.direction = face_player()
	direction_to_player = face_player()
	forward_direction = enemy.global_transform.basis.z
	side_vector = forward_direction.rotated(Vector3(0, 1, 0), deg_to_rad(90))
	
	if delta_count >= block_time && distance_to_player() < enemy.distance_to_swing:
		return state_machine.change_state(&"Swing")
	
	# enemy turns to player immediately if taken too much damage
	if enemy.health_component.current_health < instant_turn_hp_threshold:
		instant_turn_hp_threshold = enemy.health_component.current_health - enemy.instant_turn_hp_amount
		enemy.face_direction(direction_to_player)

	# rotation
	if side_vector.dot(direction_to_player) > 0.0:
		enemy.rotation.y += TURNAROUND_SPEED
	elif side_vector.dot(direction_to_player) < 0.0:
		enemy.rotation.y -= TURNAROUND_SPEED
	
	# blocking checks
	hurtbox.invincibility_frames = forward_direction.dot(direction_to_player) >= 0.0
	
	# moving away and towards player
	if distance_to_player() < enemy.aggro_range[0]:
		is_aggro = false
	elif distance_to_player() > enemy.aggro_range[1]:
		is_aggro = true
	
	if ray_cast.is_colliding() && !is_aggro:
		move_direction = Vector3.ZERO
		is_aggro = true
		if !reset_played:
			enemy.action_animator.play("basic_enemy_animation_library/RESET")
			reset_played = true
			walk_played = false
	elif is_aggro:
		move_direction = face_player()
		reset_played = false
	else:
		move_direction = face_player().rotated(Vector3(0,1,0), deg_to_rad(180))
		reset_played = false

	if !walk_played:
		enemy.action_animator.play("basic_enemy_animation_library/walk")
		walk_played = true

	enemy.velocity = move_direction * enemy.movement_component.move_speed * delta
	enemy.move_and_slide()
	
	# play footstep sound fx
	if step_timer > NEXT_STEP && move_direction != Vector3.ZERO:
		enemy.play_sound_fx("run_step_%d" % step_index)
		step_index += 1
		
		step_timer = 0.0
		if step_index > 5:
			step_index = 1

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	hurtbox.invincibility_frames = false
