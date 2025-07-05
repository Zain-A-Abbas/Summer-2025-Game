class_name JabberwockBossSweep
extends EnemyState

const SWEEP_TIME: float = 0.7
const WARNING_HIDE: float = 0.8
const DEFAULT_COOLDOWN: float = 0.65
const SWEEP_SPEED: float = deg_to_rad(5.0)
const START_DIRECTION: Array[float] = [-1, 1]
const RAGE_COST_TO_COMBO: int = 100.0

var attack_activated: bool = false
var warning_hidden: bool = false

var rage_component: JabberwockBossRageComponent
var direction: Vector3
var forward_vector: Vector3
var delta_count: float = 0.0
var cooldown: float = 0.0

var sweep: AttackObject
var sweep_direction: float = 0.0
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
	from_swipe = false
	
	# check if comboing from swipe
	if args.has('from_swipe'):
		from_swipe = true
		cooldown += args['from_swipe'] 	# increase cooldown
		
		direction = face_player().rotated(Vector3(0, 1, 0), deg_to_rad(180))
		enemy.face_direction(direction)
	elif args.has('from_shoot'):
		cooldown += args['from_shoot']
		
		direction = face_player().rotated(Vector3(0, 1, 0), deg_to_rad(180))
		enemy.face_direction(direction)
	
	forward_vector = enemy.global_transform.basis.z 			# get forward vector
	sweep_rotation_start = sweep.rotation.y 					# save initial rotation for sweep attack object
	sweep_direction = START_DIRECTION.pick_random() 			# choose to sweep left or right
	sweep.rotation.y += deg_to_rad(sweep_direction * 89.0) 	# set sweep start location
	
	enemy.attack_indicator_animator.play("show_indicator")
	
func st_physics_process(delta: float) -> void:
	delta_count += delta
	rage_component.decay_rage(delta)
	
	if delta_count > WARNING_HIDE && !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
		warning_hidden = true
	
	if forward_vector.dot(sweep.global_transform.basis.z) < 0:
		if !from_swipe && enemy.can_combo():
			rage_component.consume_rage()
			state_machine.change_state(&"Swipe", {"from_sweep": cooldown})
		else:
			state_machine.change_state(&"Idle", {"cooldown": cooldown})
		return
	
	if delta_count >= SWEEP_TIME:
		sweep.hitbox.monitorable = true
		sweep.rotation.y -= SWEEP_SPEED * sweep_direction

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	sweep.rotation.y = sweep_rotation_start
	sweep.hitbox.monitorable = false
	
	# face player
	enemy.face_direction(face_player())
