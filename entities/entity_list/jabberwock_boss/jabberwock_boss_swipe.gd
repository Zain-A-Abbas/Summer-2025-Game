class_name JabberwockBossSwipe
extends EnemyState

const CLAW_ACTIVE_FRAMES: Array[float] = [0.5371, 0.7192]
const CLAW_MIRRORED_ACTIVE_FRAMES: Array[float] = [0.5375, 0.6837]
const CLAW_WARNING_TIMES: Array[float] = [0.1, 0.6]
const CLAW_MIRRORED_WARNING_TIMES: Array[float] = [0.1, 0.5]
const CLAW_FINISH_TIME: float = 0.8134
const COOLDOWN_TIME: float = 0.675
const NEXT_SWIPE: float = 0.75
const MOVE_SPEED: float = 2000.0
const MOVE_SPEED_DECAY: float = 5.0

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
var from_shoot: bool = false
var move_speed: float
var sounds_played: float = false


func _init(new_enemy: Enemy, rage: JabberwockBossRageComponent, atk: AttackObject, other_atk: AttackObject) -> void:
	enemy = new_enemy
	rage_component = rage
	swipe = atk
	swipe_mirrored = other_atk

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	warning_hidden = false
	warning_shown = false
	sounds_played = false
	
	delta_count = 0.0
	move_speed = MOVE_SPEED
	from_sweep = false
	from_shoot = false
	
	swipe_count = 0
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
	elif args.has('from_shoot'):
		from_shoot = true
		cooldown += args['from_shoot']
	
	direction = face_player()
	enemy.face_direction(direction)
	
	if swipe_count % 2 == 1:
		current_swipe = swipe_mirrored
		warning_trackers = CLAW_MIRRORED_WARNING_TIMES
		current_active_frames = CLAW_MIRRORED_ACTIVE_FRAMES
		enemy.action_animator.play("jabberwock/claw_mirrored")
	else:
		current_swipe = swipe
		warning_trackers = CLAW_WARNING_TIMES
		current_active_frames = CLAW_ACTIVE_FRAMES
		enemy.action_animator.play("jabberwock/claw")
	
	swipe_count += 1
	enemy.pushback_speed = enemy.swipe_pushback

func st_physics_process(delta: float) -> void:
	delta_count += delta
	rage_component.decay_rage(delta)
	
	if delta_count > warning_trackers[0] && !warning_shown:
		enemy.attack_indicator_animator.play("show_indicator")
		warning_shown = true
	
	if delta_count > warning_trackers[1] && !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
		warning_hidden = true
	
	current_swipe.hitbox.monitorable = delta_count >= current_active_frames[0] && delta_count <= current_active_frames[1]
	enemy.pushback = current_swipe.hitbox.monitorable
	enemy.player.deflect_direction = face_player()
	
	if current_swipe.hitbox.monitorable:
		enemy.velocity = direction * move_speed * delta
		enemy.move_and_slide()
		
		if !sounds_played:
			enemy.play_sound_fx(&"swipe_move")
			enemy.play_sound_fx("swipe%d" % swipe_count)
			enemy.play_sound_fx(&"swipe_roar")
			sounds_played = true
	
	if move_speed >= MOVE_SPEED_DECAY:
		move_speed -= MOVE_SPEED_DECAY

	if delta_count > CLAW_FINISH_TIME:
		if n_swipes > 0:
			return state_machine.change_state(&"Swipe", {"from_swipe": true, "swipe_count": swipe_count, "remaining_swipes": n_swipes})
		elif n_swipes == 0:
			if enemy.can_combo():
				var rand: int = randi_range(0, 1)
				if rand == 0 && !from_sweep:
					rage_component.consume_rage()
					return state_machine.change_state(&"Sweep", {"from_swipe": cooldown})
				elif rand == 1 && !from_shoot:
					rage_component.consume_rage()
					return state_machine.change_state(&"Shoot", {"from_swipe": cooldown})
			return state_machine.change_state(&"Idle", {"cooldown": cooldown})
	

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	if !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
