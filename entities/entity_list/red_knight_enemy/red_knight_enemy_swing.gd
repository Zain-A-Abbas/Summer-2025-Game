class_name RedKnightEnemySwing
extends EnemyState

const TIME_TO_SWING: float = 0.4
const MOVEMENT_DURATION: float = TIME_TO_SWING + 0.15
const STATE_DURATION: float = 1.5

var attack_activated: bool= false
var attack_object: AttackObject
var direction: Vector3
var delta_count: float = 0.0


func _init(new_enemy: Enemy, atk: AttackObject) -> void:
	enemy = new_enemy
	attack_object = atk

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	direction = face_player()
	attack_activated = false
	
	enemy.face_direction(direction)

	enemy.shield_icon.hide()
	enemy.play_sound_fx(&"lift_sword")
	enemy.action_animator.play("basic_enemy_animation_library/attack")

func st_physics_process(delta: float):
	delta_count += delta

	# startup time
	if delta_count >= TIME_TO_SWING && !attack_activated:
		enemy.play_sound_fx(&"big_sword")
		attack_object.hitbox.monitorable = true
		attack_activated = true
		enemy.attack_indicator_animator.play("hide_indicator")
	
	# movement
	if attack_activated && delta_count <= MOVEMENT_DURATION:
		enemy.velocity = enemy.gravity_velocity() + direction * enemy.swing_move_speed 
		enemy.velocity *= delta
		enemy.move_and_slide()
	
	attack_object.hitbox.monitorable = attack_activated && delta_count <= MOVEMENT_DURATION
	
	if delta_count >= STATE_DURATION:
		return state_machine.change_state(&"Idle")
