class_name FlowerEnemyShoot
extends EnemyState

const BOMB = preload("res://entities/entity_list/flower_enemy/flower_enemy_bomb/flower_enemy_bomb.tscn")
const SHOOT_TIMES: Array[float] = [0.7, 1.6]
const WARNING_TIMES: Array[float] = [0.1, 0.9]

var bomb_shot: bool= false
var warning_trackers: Array[float] = [0.0, 0.0]
var warning_shown: bool = false
var warning_hidden: bool = false

var delta_count: float = 0.0
#var animation_time: float = 0.0
var atk_node: Node3D
var direction: Vector3 = Vector3.ZERO
var model: Node3D

func _init(new_enemy: Enemy, attack_object: Node3D, mod: Node3D) -> void:
	enemy = new_enemy
	atk_node = attack_object
	model = mod
	
func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	bomb_shot = false
	warning_trackers.fill(0.0)
	warning_hidden = false
	warning_shown = false
	delta_count = 0.0
	enemy.action_animator.play("basic_enemy_animation_library/attack")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	for n in warning_trackers.size():
		warning_trackers[n] += delta
	
	if warning_trackers[0] > WARNING_TIMES[0] && !warning_shown:
		enemy.attack_indicator_animator.play("show_indicator")
		warning_shown = true
	
	if warning_trackers[1] > WARNING_TIMES[1] && !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
		warning_hidden = true
		
	# enemy is always facing player
	direction = face_player()
	model.rotation.y = Vector2(direction.x, -direction.z).angle() + deg_to_rad(90)
	
	if delta_count >= SHOOT_TIMES[0] && !bomb_shot:
		bomb_shot = true
		var bomb = BOMB.instantiate()
		atk_node.add_child(bomb)
		bomb.initialize_bomb()
		bomb.global_position = enemy.player.position
		
	if delta_count > SHOOT_TIMES[1]:
		state_machine.change_state(&"Idle")
		return

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	if !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
