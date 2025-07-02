class_name JabberwockBossSweep
extends EnemyState

const SWEEP_TIME: float = 0.4
const WARNING_HIDE: float = 0.3
const DEFAULT_COOLDOWN: float = 2.0
const DEFAULT_SWEEP_SPEED: float = deg_to_rad(5.0)
const START_DIRECTION: Array[float] = [-1, 1]
const RAGE_THRESHOLD_TO_COMBO: int = 100.0
const SWEEP_SPEED_INCREASE_RAGE_THRESHOLD: int = 50

var attack_activated: bool = false
var warning_hidden: bool = false

var rage_component: JabberwockBossRageComponent
var forward_vector: Vector3
var delta_count: float = 0.0
var cooldown: float = 0.0

var sweep: AttackObject
var sweep_direction: float = 0.0
var sweep_rotation_speed: float = 0.0
var sweep_rotation_start: float = 0.0
var from_swipe: bool = false

func _init(new_enemy: Enemy, rage: JabberwockBossRageComponent, atk: AttackObject) -> void:
	enemy = new_enemy
	rage_component = rage
	sweep = atk

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	attack_activated = false
	warning_hidden = false
	
	cooldown = DEFAULT_COOLDOWN
	sweep_rotation_speed = DEFAULT_SWEEP_SPEED
	
	# face player
	var direction: Vector3 = face_player()
	enemy.rotation.y = get_angle_to_face_player(direction)
	
	forward_vector = enemy.global_transform.basis.z 	# get forward vector towards player
	sweep_rotation_start = sweep.rotation.y 			# save initial rotation for sweep attack object
	sweep_direction = START_DIRECTION.pick_random() 	# choose to sweep left or right

	# initialize sweep
	sweep.rotation.y += deg_to_rad(sweep_direction * 89.0)
	sweep.hitbox.monitorable = true
	
	# check if comboing from swipe
	if args.has('from_swipe'):
		from_swipe = true
		cooldown += args['from_swipe'] 		# increase cooldown
	
	# increase swing speed if 
	if rage_component.current_rage >= SWEEP_SPEED_INCREASE_RAGE_THRESHOLD:
		sweep_rotation_speed *= 1.5	
	
	enemy.attack_indicator_animator.play("show_indicator")
	
func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	if delta_count > WARNING_HIDE && !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
		warning_hidden = true
	
	if forward_vector.dot(sweep.global_transform.basis.z) < 0:
		if !from_swipe && can_swipe():
			state_machine.change_state(&"Swipe", {"from_sweep": cooldown})
		else:
			state_machine.change_state(&"Idle", {"cooldown": cooldown})
		return
	
	if delta_count >= SWEEP_TIME:
		sweep.rotation.y -= sweep_rotation_speed * sweep_direction

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	sweep.rotation.y = sweep_rotation_start
	sweep.hitbox.monitorable = false
	
func can_swipe() -> bool:
	if rage_component.current_rage < RAGE_THRESHOLD_TO_COMBO:
		return false
	
	var chance: int = randi_range(1, 10)
	var rage_chance_increase: int = roundf((rage_component.current_rage - RAGE_THRESHOLD_TO_COMBO) / 100.0)
	var threshold: int = 7 - rage_chance_increase
	
	return chance > threshold
