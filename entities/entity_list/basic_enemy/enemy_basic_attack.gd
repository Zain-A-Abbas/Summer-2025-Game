class_name EnemyBasicAttack
extends EnemyState

# Used to access the AnimationEffects node for visuals.
const ACTION_NAME: String = "basic_attack"
const LENGTH: float = 1.4
const MOVE_SPEED: float = 0.0
const ACTIVE_FRAMES: Array[float] = [0.6, 0.9]
const WARNING_TIMES: Array[float] = [0.3, 0.6]

var attack_activated: bool= false
var warning_trackers: Array[float] = [0.0, 0.0]
var warning_shown: bool = false
var warning_hidden: bool = false

var delta_count: float = 0.0
var animation_time: float = 0.0
var attack_object: AttackObject
var movement_vector: Vector3

var combo: int = 1

func _init(new_enemy: Enemy, object: AttackObject) -> void:
	enemy = new_enemy
	attack_object = object

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	#player.animation_effects.play(ACTION_NAME
	movement_vector = Vector3(0, 0, -MOVE_SPEED).rotated(Vector3.UP, enemy.rotation.y).normalized()
	
	attack_activated = false
	warning_trackers.fill(0.0)
	warning_hidden = false
	warning_shown = false
	delta_count = 0.0

func st_physics_process(delta: float) -> void:
	delta_count += delta
	for n in warning_trackers.size():
		warning_trackers[n] += delta
	
	attack_object.hitbox.monitorable = delta_count >= ACTIVE_FRAMES[0] && delta_count <= ACTIVE_FRAMES[1]
	if delta_count >= ACTIVE_FRAMES[0] && !attack_activated:
		attack_activated = true
		enemy.animation_effects.play("basic_attack")
	
	if delta_count > LENGTH:
		state_machine.change_state(&"Chase", {"from_attack": true})
		return
	
	if warning_trackers[0] > WARNING_TIMES[0] && !warning_shown:
		enemy.attack_indicator_animator.play("show_indicator")
		warning_shown = true
	
	if warning_trackers[1] > WARNING_TIMES[1] && !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
		warning_hidden = true
	
	enemy.velocity = movement_vector * MOVE_SPEED * delta
	enemy.move_and_slide()

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	if !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
