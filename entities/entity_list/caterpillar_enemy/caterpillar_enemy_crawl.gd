class_name CaterpillarEnemyCrawl
extends EnemyState

const CRAWL_SOUND_TIME: float = 0.6

var direction: Vector3
var delta_count: float = 0.0
var direction_timer: float = 0.0
var ray_cast: RayCast3D
var crawl_sound_index: int = 1
var crawl_sound_timer: float = 0.0

func _init(new_enemy: Enemy, ray: RayCast3D) -> void:
	enemy = new_enemy
	ray_cast = ray

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count *= 0.5 * float(args.has("no_shot"))
	direction_timer = 0.0
	crawl_sound_timer = 0.0
	crawl_sound_index = 2
	
	direction = face_player().rotated(Vector3(0, 1, 0), deg_to_rad(randf_range(-180, 180)))
	
	enemy.action_animator.play("basic_enemy_animation_library/walk")
	enemy.play_sound_fx(&"crawl_1")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	direction_timer += delta
	crawl_sound_timer += delta
	
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

	# play sfx
	if crawl_sound_timer > CRAWL_SOUND_TIME:
		enemy.play_sound_fx("crawl_%d" % crawl_sound_index)
		crawl_sound_index += 1
		
		crawl_sound_timer = 0.0
		if crawl_sound_index > 4:
			crawl_sound_index = 1
