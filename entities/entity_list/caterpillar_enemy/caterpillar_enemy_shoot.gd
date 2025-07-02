class_name CaterpillarEnemyShoot
extends EnemyState

const SEED = preload("res://entities/entity_list/caterpillar_enemy/caterpillar_enemy_seed/caterpillar_enemy_seed.tscn")
const SHOOT_TIMES: Array[float] = [0.7, 1.6]
const WARNING_TIMES: Array[float] = [0.1, 0.9]

var seed_shot: bool= false
var warning_trackers: Array[float] = [0.0, 0.0]
var warning_shown: bool = false
var warning_hidden: bool = false

var atk_node: Node3D
var direction: Vector3 = Vector3.ZERO
var delta_count: float = 0.0

func _init(new_enemy: Enemy, attack_object: Node3D) -> void:
	enemy = new_enemy
	atk_node = attack_object

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	seed_shot = false
	warning_trackers.fill(0.0)
	warning_hidden = false
	warning_shown = false
	delta_count = 0.0
	
	direction = face_player()
	enemy.rotation.y = get_angle_to_face_player(direction)
	
	enemy.action_animator.play("basic_enemy_animation_library/RESET")
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

	if delta_count >= SHOOT_TIMES[0] && !seed_shot:
		seed_shot = true
	
		var seed = SEED.instantiate()
		enemy.projectiles.add_child(seed)
		seed.initialize_seed(false, face_player(), enemy.projectiles)
		seed.global_position = enemy.global_position
		
	if delta_count > SHOOT_TIMES[1]:
		state_machine.change_state(&"Idle")
		return
		
