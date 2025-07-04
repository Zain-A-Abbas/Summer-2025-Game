class_name JabberwockBossSwipe
extends EnemyState

const ACTIVE_FRAMES: Array[float] = [0.55, 0.85]
const WARNING_TIMES: Array[float] = [0.1, 0.65]
const COOLDOWN_TIME: float = 0.65
const NEXT_SWIPE: float = 1.2
const MOVE_SPEED: float = 1500.0

var attack_activated: bool = false
var warning_trackers: Array[float] = [0.0, 0.0]
var warning_shown: bool = false
var warning_hidden: bool = false

var rage_component: JabberwockBossRageComponent
var swipe: AttackObject
var n_swipes: int = 0
var swipe_count: int = 0

var delta_count: float = 0.0
var cooldown: float = 0.0
var direction: Vector3
var from_sweep: bool = false

func _init(new_enemy: Enemy, rage: JabberwockBossRageComponent, atk: AttackObject) -> void:
	enemy = new_enemy
	rage_component = rage
	swipe = atk

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	attack_activated = false
	warning_trackers.fill(0.0)
	warning_hidden = false
	warning_shown = false
	
	delta_count = 0.0
	from_sweep = false
	
	swipe_count = 0
	n_swipes = randi_range(1, 3)

	cooldown = n_swipes * COOLDOWN_TIME
	if args.has('from_sweep'):
		from_sweep = true
		cooldown += args['from_sweep']	# increase cooldown
	
	direction = face_player()
	enemy.rotation.y = get_angle_to_face_player(direction)

func st_physics_process(delta: float) -> void:
	delta_count += delta
	rage_component.decay_rage(delta)
	
	for n in warning_trackers.size():
		warning_trackers[n] += delta
	
	if warning_trackers[0] > WARNING_TIMES[0] && !warning_shown:
		enemy.attack_indicator_animator.play("show_indicator")
		warning_shown = true
	
	if warning_trackers[1] > WARNING_TIMES[1] && !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
		warning_hidden = true
	
	swipe.hitbox.monitorable = delta_count >= ACTIVE_FRAMES[0] && delta_count <= ACTIVE_FRAMES[1]
	if swipe.hitbox.monitorable:
		enemy.velocity = direction * MOVE_SPEED * delta
		enemy.move_and_slide()

	if delta_count >= ACTIVE_FRAMES[0] && !attack_activated:
		attack_activated = true
		swipe_count += 1
		#print("swiped ", swipe_count)
		enemy.action_animator.play("basic_enemy_animation_library/attack")
	
	if delta_count >= NEXT_SWIPE && swipe_count != n_swipes:
		warning_hidden = false
		warning_shown = false
		attack_activated = false
		delta_count = 0.0
		warning_trackers.fill(0.0)
		enemy.action_animator.play("basic_enemy_animation_library/RESET")
		
		direction = face_player()
		enemy.rotation.y = get_angle_to_face_player(direction)
	
	if swipe_count == n_swipes && !swipe.hitbox.monitorable:
		if !from_sweep && enemy.can_combo():
			rage_component.consume_rage()
			return state_machine.change_state(&"Sweep", {"from_swipe": cooldown})
		else:
			return state_machine.change_state(&"Idle", {"cooldown": cooldown})

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	if !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
