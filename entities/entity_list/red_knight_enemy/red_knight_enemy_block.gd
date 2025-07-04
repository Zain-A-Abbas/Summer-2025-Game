class_name RedKnightEnemyBlock
extends EnemyState

const TURNAROUND_SPEED: float = deg_to_rad(1.0)
const INSTANT_TURN_HP_OFFSET: int = 40
const AGGRO_RADIUS: float = 9.0
const DEAGGRO_RADIUS: float = 2.0
const DISTANCE_TO_ATTACK: float = 7.0
#const PLAYER_PUSHBACK: float = 300.0

var hurtbox: HurtboxComponent
var side_vector: Vector3
var forward_direction: Vector3
var direction_to_player: Vector3
var move_direction: Vector3

var block_time: float = 0.0
var instant_turn_hp_threshold: int = 0
var delta_count: float = 0.0
var is_aggro: bool = true

func _init(new_enemy: Enemy, hb: HurtboxComponent) -> void:
	enemy = new_enemy
	hurtbox = hb

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	
	direction_to_player = face_player()
	enemy.rotation.y = get_angle_to_face_player(direction_to_player)

	block_time = randf_range(4.0, 5.5)
	instant_turn_hp_threshold = enemy.health_component.current_health - INSTANT_TURN_HP_OFFSET
	is_aggro = true
	
	enemy.action_animator.play("basic_enemy_animation_library/walk")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	direction_to_player = face_player()
	forward_direction = enemy.global_transform.basis.z
	side_vector = forward_direction.rotated(Vector3(0, 1, 0), deg_to_rad(90))
	
	if delta_count >= block_time && distance_to_player() < DISTANCE_TO_ATTACK:
		state_machine.change_state(&"Swing")
		return
	
	# enemy turns to player immediately if taken too much damage
	if enemy.health_component.current_health < instant_turn_hp_threshold:
		instant_turn_hp_threshold = enemy.health_component.current_health - INSTANT_TURN_HP_OFFSET
		enemy.rotation.y = get_angle_to_face_player(direction_to_player)
		#print("turned around")

	# rotation
	if side_vector.dot(direction_to_player) > 0.0:
		enemy.rotation.y += TURNAROUND_SPEED
	elif side_vector.dot(direction_to_player) < 0.0:
		enemy.rotation.y -= TURNAROUND_SPEED
	
	# blocking checks
	if forward_direction.dot(direction_to_player) > 0.0:
		hurtbox.invincibility_frames = true
		#print("in front")
	elif forward_direction.dot(direction_to_player) < 0.0:
		hurtbox.invincibility_frames = false
		#print("behind")
	
	# moving away and towards player
	if distance_to_player() < DEAGGRO_RADIUS:
		is_aggro = false
	elif distance_to_player() > AGGRO_RADIUS:
		is_aggro = true

	if is_aggro:
		move_direction = face_player()
	else:
		move_direction = face_player().rotated(Vector3(0,1,0), deg_to_rad(180))

	enemy.velocity = move_direction * enemy.movement_component.move_speed * delta
	enemy.move_and_slide()

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	hurtbox.invincibility_frames = false
