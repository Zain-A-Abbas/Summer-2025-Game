class_name MouseEnemyDig
extends EnemyState

const DIG_SOUND_TIME: float = 0.3

var ray_cast: RayCast3D
var delta_count: float = 0.0
var dig_sound_timer: float = 0.0
var direction: Vector3 = Vector3.ZERO
var random_direction_timer: float = 0.0
var dig_sound_index: int = 0
var is_underground: bool = false
var speed_type: StringName


func _init(new_enemy: Enemy, ray: RayCast3D) -> void:
	enemy = new_enemy
	ray_cast = ray

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	random_direction_timer = 0.0
	dig_sound_timer = 0.0
	
	dig_sound_index = 2
	is_underground = false
	
	speed_type = &"digging_down"
	direction = face_player().rotated(Vector3(0, 1, 0), deg_to_rad(180))
	
	# play dig animation here
	enemy.play_sound_fx(&"digging_1")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	random_direction_timer += delta
	dig_sound_timer += delta

	if delta_count >= enemy.dig_duration:
		enemy.play_sound_fx(&"resurface")
		return state_machine.change_state(&"Idle")
	
	enemy.hurtbox.invincibility_frames = delta_count > enemy.underground_timestamp
	
	if !is_underground && enemy.hurtbox.invincibility_frames:
		enemy.hide() # TEMPORARY underground animation
		is_underground = true
		speed_type = &"underground"
	
	# change direction
	if random_direction_timer >= enemy.change_direction_timestamp:
		direction = direction.rotated(Vector3(0, 1, 0), deg_to_rad(randf_range(-90, 90)))
		random_direction_timer = 0.0

	if ray_cast.is_colliding():
		direction = direction.rotated(Vector3(0, 1, 0), deg_to_rad(40))

	enemy.velocity = direction * enemy.dig_speeds[speed_type] * delta
	enemy.face_direction(direction)
	enemy.move_and_slide()
	
	# play digging sfx
	if dig_sound_timer > DIG_SOUND_TIME:
		enemy.play_sound_fx("digging_%d" % dig_sound_index)
		dig_sound_index += 1
		
		dig_sound_timer = 0.0
		if dig_sound_index > 4:
			dig_sound_index = 1
	

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	enemy.hurtbox.invincibility_frames = false
	enemy.show()
