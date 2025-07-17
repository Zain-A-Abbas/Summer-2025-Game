class_name JabberwockBossSwipe
extends EnemyState

const CLAW_ACTIVE_FRAMES: Array[float] = [0.8, 1.167]
const CLAW_MIRRORED_ACTIVE_FRAMES: Array[float] = [0.75, 0.95]
const CLAW_WARNING_TIMES: Array[float] = [0.4, 0.7]
const CLAW_MIRRORED_WARNING_TIMES: Array[float] = [0.3, 0.65]

const CLAW_FINISH_TIME: float = 1.2

const COOLDOWN_TIME: float = 0.65
const NEXT_SWIPE: float = 1.2
const MOVE_SPEED: float = 1500.0

var attack_activated: bool = false
var warning_trackers: Array[float] = [0.0, 0.0]
var current_active_frames: Array[float] = [0.0, 0.0]
var warning_shown: bool = false
var warning_hidden: bool = false

var rage_component: JabberwockBossRageComponent
var swipe: AttackObject
var swipe_mirrored: AttackObject
var current_swipe: AttackObject
var n_swipes: int = 0
var swipe_count: int = 0

var direction: Vector3
var delta_count: float = 0.0
var cooldown: float = 0.0
var from_sweep: bool = false


func _init(new_enemy: Enemy, rage: JabberwockBossRageComponent, atk: AttackObject, other_atk: AttackObject) -> void:
	enemy = new_enemy
	rage_component = rage
	swipe = atk
	swipe_mirrored = other_atk

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	attack_activated = false
	warning_hidden = false
	warning_shown = false
	
	delta_count = 0.0
	from_sweep = false
	
	swipe_count = 1
	if args.has("from_swipe"):
		swipe_count = args["swipe_count"]
		n_swipes = args["remaining_swipes"]
	else:
		n_swipes = randi_range(1, 3)
	
	n_swipes -= 1
	
	cooldown = n_swipes * COOLDOWN_TIME
	if args.has('from_sweep'):
		from_sweep = true
		cooldown += args['from_sweep']	# increase cooldown
	
	direction = face_player()
	enemy.face_direction(direction)
	
	if swipe_count % 2 == 0:
		current_swipe = swipe_mirrored
		warning_trackers = CLAW_MIRRORED_WARNING_TIMES
		current_active_frames = CLAW_MIRRORED_ACTIVE_FRAMES
		enemy.animation_tree["parameters/claw_mirrored_oneshot/request"] = 1
	else:
		current_swipe = swipe
		warning_trackers = CLAW_WARNING_TIMES
		current_active_frames = CLAW_ACTIVE_FRAMES
		enemy.animation_tree["parameters/claw_oneshot/request"] = 1
	
	swipe_count += 1
	

func st_physics_process(delta: float) -> void:
	delta_count += delta
	rage_component.decay_rage(delta)
	
	if delta_count > warning_trackers[0] && !warning_shown:
		enemy.attack_indicator_animator.play("show_indicator")
		warning_shown = true
	
	if delta_count > warning_trackers[1] && !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
		warning_hidden = true
	
	current_swipe.hitboxes[0].monitorable = delta_count >= current_active_frames[0] && delta_count <= current_active_frames[1]
	
	if current_swipe.hitboxes[0].monitorable:
		enemy.velocity = direction * MOVE_SPEED * delta
		enemy.move_and_slide()
	
	if delta_count > CLAW_FINISH_TIME:
		if n_swipes > 0:
			return state_machine.change_state(&"Swipe", {"from_swipe": true, "swipe_count": swipe_count, "remaining_swipes": n_swipes})
		elif n_swipes == 0:
			if !from_sweep && enemy.can_combo():
				rage_component.consume_rage()
				return state_machine.change_state(&"Sweep", {"from_swipe": cooldown})
			else:
				return state_machine.change_state(&"Idle", {"cooldown": cooldown})
	

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	if !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
