class_name CaterpillarEnemyCrawl
extends EnemyState

var direction: Vector3
var delta_count: float = 0.0
var direction_timer: float = 0.0
var ray_cast: RayCast3D


func _init(new_enemy: Enemy, ray: RayCast3D) -> void:
	enemy = new_enemy
	ray_cast = ray

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count *= 0.5 * float(args.has("no_shot"))
	direction_timer = 0.0
	
	direction = face_player().rotated(Vector3(0, 1, 0), deg_to_rad(randf_range(-180, 180)))
	
	enemy.action_animator.play("basic_enemy_animation_library/walk")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	direction_timer += delta
	
	if delta_count >= enemy.crawl_duration:
		if ray_cast.is_colliding():
			return state_machine.change_state(&"Crawl", {"no_shot" = true})
		elif distance_to_player() < enemy.shooting_range:
			return state_machine.change_state(&"Shoot")
		else:
			delta_count = 0.0
	
	if direction_timer > enemy.change_direction_timestamp:
		if !ray_cast.is_colliding():
			direction = direction.rotated(Vector3(0, 1, 0), deg_to_rad(randf_range(-90, 90)))
		direction_timer = 0.0
	
	if ray_cast.is_colliding():
		direction = direction.rotated(Vector3(0, 1, 0), deg_to_rad(40))
	
	enemy.velocity = direction * enemy.movement_component.move_speed * delta
	enemy.face_direction(direction)
	enemy.move_and_slide()
