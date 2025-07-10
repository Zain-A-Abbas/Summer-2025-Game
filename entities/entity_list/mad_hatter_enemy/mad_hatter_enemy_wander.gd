class_name MadHatterEnemyWander
extends EnemyState

const HOP_TIME: float = 0.35

var direction: Vector3 = Vector3.ZERO
var ray_cast: RayCast3D
var move_speed: float = 0.0
var delta_count: float = 0.0
var hop_timer: float = 0.0
var random_direction_timer: float = 0.0
var is_hopping: bool = false


func _init(new_enemy: Enemy, ray: RayCast3D) -> void:
	enemy = new_enemy
	ray_cast = ray

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	hop_timer = 0.0
	random_direction_timer = 0.0
	
	move_speed = enemy.movement_component.move_speed
	direction = face_player().rotated(Vector3(0, 1, 0), deg_to_rad(180))
	
	enemy.action_animator.play("mad_hatter_animations/walk")
	enemy.play_sound_fx(&"jump")
	is_hopping = true

func st_physics_process(delta: float) -> void:
	delta_count += delta
	hop_timer += delta
	random_direction_timer += delta
	
	# play movement sfx
	if hop_timer > HOP_TIME && !is_hopping:
		enemy.play_sound_fx(&"jump")
		is_hopping = true
		hop_timer = 0.0
	
	if hop_timer > HOP_TIME && is_hopping:
		enemy.play_sound_fx(&"land")
		is_hopping = false
		hop_timer = 0.0
	
	# increase movement speed overtime
	if move_speed < enemy.max_speed:
		move_speed += 1.5
		#enemy.animation_tree["parameters/WalkRun/blend_position"] = move_toward(enemy.animation_tree["parameters/WalkRun/blend_position"], 1.0, delta * 4.0)
	
	# transition to summon state
	if delta_count >= enemy.wander_duration:
		#enemy.animation_tree["parameters/WalkRun/blend_position"] = 0.0
		return state_machine.change_state(&"Summon")
	
	# changing directions for movement
	if random_direction_timer >= enemy.change_direction_time:
		if !ray_cast.is_colliding():
			direction = direction.rotated(Vector3(0, 1, 0), deg_to_rad(randf_range(-180, 180)))
		random_direction_timer = 0.0
	
	if ray_cast.is_colliding():
		direction = direction.rotated(Vector3(0, 1, 0), deg_to_rad(40))

	enemy.velocity = direction * move_speed * delta
	enemy.face_direction(direction)
	enemy.move_and_slide()
