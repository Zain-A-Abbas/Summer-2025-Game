class_name MadHatterEnemyWander
extends EnemyState

const WANDER_TIME: float = 4.0
const MAX_SPEED: float = 600
const CLOSE_TO_STOP: float = 0.7
const HOP_TIME: float = 0.1
const TIME_TO_LAND: float = 0.4

var move_speed: float = 0.0
var delta_count: float = 0.0
var hop_timer: float = 0.0
var direction: Vector3 = Vector3.ZERO
var hatter_stops: Node3D
var marker_index: int = 0
var is_hopping: bool = false

func _init(new_enemy: Enemy, path: Node3D) -> void:
	enemy = new_enemy
	hatter_stops = path

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	if args.has("next_stop") && args["next_stop"]:
		move_speed = args["move_speed"]
		marker_index += 1
	else:
		move_speed = enemy.movement_component.move_speed
		delta_count = 0.0
		hop_timer = 0.0
		is_hopping = false
	
	direction = enemy.position.direction_to(hatter_stops.get_child(marker_index).position)
	direction = Vector3(direction.x, 0, direction.z)
	
	enemy.action_animator.play("basic_enemy_animation_library/walk")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	hop_timer += delta
	
	# play movement sfx
	if hop_timer > HOP_TIME && !is_hopping:
		enemy.play_sound_fx(enemy.sounds, &"jump")
		is_hopping = true
		hop_timer = 0.0
	
	if hop_timer > TIME_TO_LAND && is_hopping:
		enemy.play_sound_fx(enemy.sounds, &"land")
		is_hopping = false
		hop_timer = 0.0
	
	if move_speed < MAX_SPEED:
		move_speed += 2.0
		enemy.animation_tree["parameters/WalkRun/blend_position"] = move_toward(enemy.animation_tree["parameters/WalkRun/blend_position"], 1.0, delta * 4.0)
	
	if delta_count >= WANDER_TIME:
		state_machine.change_state(&"Summon")
		enemy.animation_tree["parameters/WalkRun/blend_position"] = 0.0
		return
	
	if enemy.position.distance_to(hatter_stops.get_child(marker_index).position) <= CLOSE_TO_STOP:
		state_machine.change_state(&"Wander", {
			"next_stop": true,
			"move_speed": move_speed
		})
		return

	enemy.velocity = direction * move_speed * delta
	enemy.rotation.y = get_angle_to_face_player(direction)
	enemy.move_and_slide()

func exit_state(previous_state: State, args: Dictionary[String, Variant]):	
	if marker_index == hatter_stops.get_child_count() - 1:
		marker_index = -1
