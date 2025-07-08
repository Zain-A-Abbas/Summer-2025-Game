class_name EnemyWander
extends EnemyState

const WALK_TIME: float = 0.5

var wander_speed: float = 0.0
var wander_timer: float = 0.0
var direction_timer: float = 0.0
var direction: Vector3 = Vector3.ZERO

var ray_cast: RayCast3D
var step_timer: float = 0.0
var step_index: int = 1


func _init(new_enemy: Enemy, ray: RayCast3D) -> void:
	enemy = new_enemy
	ray_cast = ray

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	direction_timer = 0.0
	wander_timer = 0.0
	step_timer = 0.0
	
	direction = face_player()
	wander_speed = enemy.movement_component.move_speed * 0.5
	enemy.animation_tree["parameters/WalkRun/blend_position"] = 0.0

func st_physics_process(delta: float) -> void:
	wander_timer += delta
	direction_timer += delta
	step_timer += delta
	
	if distance_to_player() <= enemy.active_radius:
		return state_machine.change_state(&"Chase")

	if wander_timer > enemy.wander_duration:
		return state_machine.change_state(&"Wander")
	
	if direction_timer >= enemy.change_direction_timestamp:
		direction = direction.rotated(Vector3.UP, deg_to_rad(randf_range(90, 135)))
		direction_timer = 0.0
	
	# if enemy is too far away but can see player
	if ray_cast.is_colliding() && distance_to_player() > enemy.active_radius:
		var collider: Object = ray_cast.get_collider()
		if collider.get_collision_layer_value(5):
			return state_machine.change_state(&"Chase")
	
	enemy.velocity = direction * wander_speed * delta
	enemy.face_direction(direction)
	enemy.move_and_slide()

	# play footstep sound fx
	if step_timer > WALK_TIME:
		enemy.play_sound_fx("run_step_%d" % step_index)
		step_index += 1
		
		step_timer = 0.0
		if step_index > 4:
			step_index = 1
