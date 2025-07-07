class_name PlayerBasicAttack
extends PlayerState

# Used to access the AnimationEffects node for visuals.
const ACTION_NAME: String = "basic_attack"
const LENGTH: float = 0.2
const CANCEL_THRESHOLD: float = 0.09
const COMBO_TIME: float = 0.4
const MOVE_SPEED: float = 400.0
const ACTIVE_FRAMES: Array[float] = [0.06, 0.12]

var delta_count: float = 0.0
var animation_time: float = 0.0
var attack_object: AttackObject
var movement_vector: Vector3
var time_on_last_attack: float
var combo: int = 1

func _init(new_player: Player, object: AttackObject) -> void:
	player = new_player
	attack_object = object

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	player.animation_effects.play(ACTION_NAME)
	
	var is_combo: bool = args.has("combo") || Time.get_ticks_msec() / 1000.0 - time_on_last_attack < COMBO_TIME
	
	if is_combo:
		combo += + 1
	else:
		combo = 1
	
	# Flip second attack
	if combo == 2:
		attack_object.scale.x = -1
	else:
		attack_object.scale.x = 1 
		player.animation_tree["parameters/Attack1TimeSeek/seek_request"] = 0.3
	
	movement_vector = Vector3(0, 0, -MOVE_SPEED).rotated(Vector3.UP, player.rotation.y).normalized()
	
	player.play_sound_fx(player.sounds, "sword_whoosh_%d" % ((combo % 3) + 1))
	player.action_animator.play("attack_%d" % ((combo % 2) + 1))

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	attack_object.hitbox.monitorable = delta_count >= ACTIVE_FRAMES[0] && delta_count <= ACTIVE_FRAMES[1]
	
	if delta_count > CANCEL_THRESHOLD:
		if Input.is_action_just_pressed("dodge") && player.can_dodge():
			state_machine.change_state(&"Dodge")
			return
		
		if Input.is_action_just_pressed("attack") && combo < 3:
			state_machine.change_state(&"Attack", {"combo": combo})
			return
	
	if delta_count > LENGTH:
		state_machine.change_state(&"Idle")
		return
	
	player.velocity = player.gravity_velocity() + movement_vector * MOVE_SPEED
	player.velocity *= delta
	player.move_and_slide()

func exit_state(next_state: State, args: Dictionary[String, Variant]):
	time_on_last_attack = Time.get_ticks_msec() / 1000.0
	player.animation_tree["parameters/Attack1/request"] = 2
	player.animation_tree["parameters/Attack2/request"] = 2
