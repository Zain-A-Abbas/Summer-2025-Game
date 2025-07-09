class_name FlowerEnemyShoot
extends EnemyState

var bomb_shot: bool= false
var warning_trackers: Array[float] = [0.0, 0.0]
var warning_shown: bool = false
var warning_hidden: bool = false

var delta_count: float = 0.0
var shoot_times: Array[float] = [0.0, 0.0]
var warning_times: Array[float] = [0.0, 0.0]
var dig_on_cooldown: bool = false


func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	bomb_shot = false
	warning_trackers.fill(0.0)
	warning_hidden = false
	warning_shown = false
	delta_count = 0.0
	
	# initialize shoot and warning times
	shoot_times[0] = randf_range(0.7, 1.2)
	shoot_times[1] = shoot_times[0] + enemy.shoot_cooldown
	
	warning_times[0] = shoot_times[0] - 0.6
	warning_times[1] = warning_times[0] + enemy.warning_duration
	
	dig_on_cooldown = args["dig_on_cooldown"]

func st_physics_process(delta: float) -> void:
	delta_count += delta
	enemy.dig_timer += delta
	for n in warning_trackers.size():
		warning_trackers[n] += delta
	
	if warning_trackers[0] > warning_times[0] && !warning_shown:
		enemy.attack_indicator_animator.play("show_indicator")
		enemy.play_sound_fx(&"shoot_bomb")
		warning_shown = true
	
	if warning_trackers[1] > warning_times[1] && !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
		warning_hidden = true
		
	# enemy is always facing player
	enemy.face_direction(face_player())
	
	if delta_count >= shoot_times[0] && !bomb_shot:
		bomb_shot = true
		var bomb: FlowerEnemyBomb = enemy.bomb.instantiate()
		enemy.projectiles.add_child(bomb)
		bomb.initialize_bomb()
		bomb.global_position = enemy.player.global_position
		
		enemy.action_animator.play("basic_enemy_animation_library/attack")
		
	if delta_count > shoot_times[1]:
		return state_machine.change_state(&"Idle", {"dig_on_cooldown": dig_on_cooldown})

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	if !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
