class_name MouseEnemyRun
extends EnemyState

const STEP_TIME: float = 0.3

var delta_count: float = 0.0
var step_timer: float = 0.0
var random_direction_timer: float = 0.0

var ray_cast: RayCast3D
var direction: Vector3 = Vector3.ZERO
var move_speed: float
var step_index = 1


func _init(new_enemy: Enemy, ray: RayCast3D) -> void:
	enemy = new_enemy
	ray_cast = ray

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	step_timer = 0.0
	random_direction_timer = 0.0
	step_index = 2
	
	direction = face_player().rotated(Vector3(0, 1, 0), deg_to_rad(180))
	
	move_speed = enemy.movement_component.move_speed
	enemy.action_animator.play("mouse/run") 
	
	enemy.play_sound_fx(enemy.sounds, "crawl_1")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	step_timer += delta
	random_direction_timer += delta

	if delta_count >= enemy.run_duration:
		if distance_to_player() >= enemy.active_range[1]:
			return state_machine.change_state(&"Run")
		elif distance_to_player() < enemy.active_range[0]:
			return state_machine.change_state(&"Dig")	
		else:
			return state_machine.change_state(&"Charge")	

	# change direction
	if random_direction_timer >= enemy.change_direction_timestamp:
		direction = direction.rotated(Vector3(0, 1, 0), deg_to_rad(randf_range(-45, 45)))
		random_direction_timer = 0.0

	if ray_cast.is_colliding():
		direction = direction.rotated(Vector3(0, 1, 0), deg_to_rad(40))

	# enemy slows downs over time
	if move_speed >= enemy.minimum_speed:
		move_speed -= 2.0
		enemy.animation_tree["parameters/WalkRun/blend_position"] = move_toward(enemy.animation_tree["parameters/WalkRun/blend_position"], 0, delta * 4.0)

	enemy.velocity = direction * move_speed * delta
	enemy.face_direction(direction)
	enemy.move_and_slide()

	# play footstep sound fx
	if step_timer > STEP_TIME:
		enemy.play_sound_fx(enemy.sounds, "crawl_%d" % step_index)
		step_index += 1
		
		step_timer = 0.0
		if step_index > 5:
			step_index = 1
