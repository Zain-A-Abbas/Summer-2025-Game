class_name CaterpillarEnemyShoot
extends EnemyState

var seed_shot: bool= false
var warning_trackers: Array[float] = [0.0, 0.0]
var warning_shown: bool = false
var warning_hidden: bool = false

var ray_cast: RayCast3D
var direction: Vector3 = Vector3.ZERO
var delta_count: float = 0.0

func _init(new_enemy: Enemy, ray: RayCast3D) -> void:
	enemy = new_enemy
	ray_cast = ray

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	seed_shot = false
	warning_trackers.fill(0.0)
	warning_hidden = false
	warning_shown = false
	delta_count = 0.0
	
	direction = face_player()
	enemy.face_direction(face_player())
	
	#enemy.action_animator.play("basic_enemy_animation_library/RESET")
	#enemy.action_animator.play("basic_enemy_animation_library/attack")
	
func st_physics_process(delta: float) -> void:
	delta_count += delta
	for n in warning_trackers.size():
		warning_trackers[n] += delta
	
	if warning_trackers[0] > enemy.warning_times[0] && !warning_shown:
		enemy.show_attack_indicator()
		warning_shown = true
	
	if warning_trackers[1] > enemy.warning_times[1] && !warning_hidden:
		enemy.hide_attack_indicator()
		warning_hidden = true

	if delta_count >= enemy.shoot_times[0] && !seed_shot:
		seed_shot = true
		enemy.play_sound_fx(&"seed_shoot")
	
		var seed = enemy.seed.instantiate()
		enemy.projectiles.add_child(seed)
		seed.initialize_seed(false, face_player(), enemy.projectiles)
		seed.global_position = enemy.global_position
		
	if delta_count > enemy.shoot_times[1]:
		return state_machine.change_state(&"Idle")
	
	enemy.face_direction(face_player())
