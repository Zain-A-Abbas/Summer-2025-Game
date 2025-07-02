class_name RedKnightEnemySwing
extends EnemyState

const MOVE_SPEED: float = 3000.0

var warning_shown: bool = false
var attack_activated: bool= false
var attack_object: AttackObject
var direction: Vector3

var delta_count: float = 0.0
var time_to_swing: float = 0.0
var swing_duration: float = 0.0
var warning_time: float = 0.0

func _init(new_enemy: Enemy, atk: AttackObject) -> void:
	enemy = new_enemy
	attack_object = atk

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	direction = face_player()
	attack_activated = false
	warning_shown = false
	
	time_to_swing = randf_range(0.5, 1.2)
	swing_duration = time_to_swing + 0.1
	warning_time = time_to_swing - 0.5
	
	enemy.rotation.y = get_angle_to_face_player(direction)
	
	enemy.action_animator.play("basic_enemy_animation_library/RESET")

func st_physics_process(delta: float) -> void:
	delta_count += delta

	# show indicator
	if delta_count >= warning_time && !warning_shown:
		enemy.attack_indicator_animator.play("show_indicator")
		warning_shown = true

	# startup time
	if delta_count >= time_to_swing && !attack_activated:
		attack_object.hitbox.monitorable = true
		attack_activated = true
		enemy.animation_effects.play("basic_attack")
	
	if attack_activated:
		enemy.velocity = direction * MOVE_SPEED * delta
		enemy.move_and_slide()
	
	if delta_count >= swing_duration:
		attack_object.hitbox.monitorable = false
		state_machine.change_state(&"Idle", {"from_swing": true})
		return

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	enemy.attack_indicator_animator.play("hide_indicator")
