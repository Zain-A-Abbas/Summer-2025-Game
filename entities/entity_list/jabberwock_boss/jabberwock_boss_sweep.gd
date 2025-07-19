class_name JabberwockBossSweep
extends EnemyState

const WARNING_HIDE: float = 1.15
const DEFAULT_COOLDOWN: float = 0.65
const RAGE_COST_TO_COMBO: int = 100.0
const SWEEP_TIME: float = 0.9768
const SWEEP_FINISH_TIME: float = 1.4194

var sound_played: bool = false
var warning_hidden: bool = false
var rage_component: JabberwockBossRageComponent
var forward_vector: Vector3
var delta_count: float = 0.0
var cooldown: float = 0.0
var sweep: AttackObject
var from_swipe: bool = false

func _init(new_enemy: Enemy, rage: JabberwockBossRageComponent, atk: AttackObject) -> void:
	enemy = new_enemy
	rage_component = rage
	sweep = atk

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	cooldown = DEFAULT_COOLDOWN
	warning_hidden = false
	from_swipe = false
	sound_played = false
	
	# check if comboing from swipe
	if args.has('from_swipe'):
		from_swipe = true
		cooldown += args['from_swipe'] 	# increase cooldown
	elif args.has('from_shoot'):
		cooldown += args['from_shoot']

	enemy.face_direction(face_player())
	forward_vector = enemy.global_transform.basis.z # get forward vector
	
	enemy.pushback_speed = enemy.sweep_pushback
	enemy.action_animator.play("jabberwock/sweep")
	enemy.attack_indicator_animator.play("show_indicator")
	enemy.play_sound_fx(&"sweep_roar")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	rage_component.decay_rage(delta)

	if delta_count > WARNING_HIDE && !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
		warning_hidden = true
	
	if delta_count >= SWEEP_TIME - 0.15 && !sound_played:
		enemy.play_sound_fx(&"sweep")
		sound_played = true
	
	sweep.hitbox.monitorable = delta_count >= SWEEP_TIME && delta_count < SWEEP_FINISH_TIME - 0.1
	enemy.pushback = sweep.hitbox.monitorable
	enemy.player.deflect_direction = face_player()

	if delta_count >= SWEEP_FINISH_TIME:
		if !from_swipe && enemy.can_combo():
			rage_component.consume_rage()
			state_machine.change_state(&"Swipe", {"from_sweep": cooldown})
		else:
			state_machine.change_state(&"Idle", {"cooldown": cooldown})
		return
