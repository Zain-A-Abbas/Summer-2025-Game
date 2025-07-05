class_name FlowerEnemyShoot
extends EnemyState

const BOMB = preload("res://entities/entity_list/flower_enemy/flower_enemy_bomb/flower_enemy_bomb.tscn")
const WARNING_DURATION: float = 0.8
const SHOT_COOLDOWN: float = 1.1

var bomb_shot: bool= false
var warning_trackers: Array[float] = [0.0, 0.0]
var warning_shown: bool = false
var warning_hidden: bool = false

var delta_count: float = 0.0
var shoot_times: Array[float] = [0.0, 0.0]
var warning_times: Array[float] = [0.0, 0.0]
var direction: Vector3 = Vector3.ZERO
	
func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	bomb_shot = false
	warning_trackers.fill(0.0)
	warning_hidden = false
	warning_shown = false
	delta_count = 0.0
	
	# initialize shoot and warning times
	shoot_times[0] = randf_range(0.7, 1.2)
	shoot_times[1] = shoot_times[0] + SHOT_COOLDOWN
	
	warning_times[0] = shoot_times[0] - 0.6
	warning_times[1] = warning_times[0] + WARNING_DURATION
	
	enemy.action_animator.play("basic_enemy_animation_library/attack")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	for n in warning_trackers.size():
		warning_trackers[n] += delta
	
	if warning_trackers[0] > warning_times[0] && !warning_shown:
		enemy.attack_indicator_animator.play("show_indicator")
		warning_shown = true
	
	if warning_trackers[1] > warning_times[1] && !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
		warning_hidden = true
		
	# enemy is always facing player
	direction = face_player()
	enemy.rotation.y = get_angle_to_face_player(direction)
	
	if delta_count >= shoot_times[0] && !bomb_shot:
		bomb_shot = true
		var bomb = BOMB.instantiate()
		enemy.projectiles.add_child(bomb)
		bomb.initialize_bomb()
		bomb.global_position = enemy.player.global_position
		
		enemy.play_sound_fx(enemy.sounds, &"shoot_bomb")
		
	if delta_count > shoot_times[1]:
		return state_machine.change_state(&"Idle")

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	if !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
