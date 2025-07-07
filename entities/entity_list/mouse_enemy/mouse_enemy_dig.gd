class_name MouseEnemyDig
extends EnemyState

const DIG_TIME: float = 3.5
const DIG_SPEEDS: Array[float] = [150.0, 650.0]
const INVULN_TIME: float = 0.8
const CHANGE_DIRECTION_TIME: float = 1.2

var ray_cast: RayCast3D
var delta_count: float = 0.0
var direction: Vector3 = Vector3.ZERO
var random_direction_timer: float = 0.0
var is_underground: bool = false
func _init(new_enemy: Enemy, ray: RayCast3D) -> void:
	enemy = new_enemy
	ray_cast = ray

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	random_direction_timer = 0.0
	is_underground = false
	
	direction = face_player().rotated(Vector3(0, 1, 0), deg_to_rad(180))
	
	# play dig animation here
	enemy.play_sound_fx(enemy.sounds, &"dig")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	random_direction_timer += delta

	if delta_count >= DIG_TIME:
		return state_machine.change_state(&"Idle")
	
	enemy.hurtbox.invincibility_frames = delta_count > INVULN_TIME
	
	if !is_underground && enemy.hurtbox.invincibility_frames:
		enemy.hide() # TEMPORARY underground animation
		is_underground = true
	
	# change direction
	if random_direction_timer >= CHANGE_DIRECTION_TIME:
		direction = direction.rotated(Vector3(0, 1, 0), deg_to_rad(randf_range(-90, 90)))
		random_direction_timer = 0.0

	if ray_cast.is_colliding():
		direction = direction.rotated(Vector3(0, 1, 0), deg_to_rad(40))

	enemy.velocity = direction * DIG_SPEEDS[int(delta_count > INVULN_TIME)] * delta
	enemy.face_direction(direction)
	enemy.move_and_slide()

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	enemy.hurtbox.invincibility_frames = false
	enemy.play_sound_fx(enemy.sounds, &"resurface")
	enemy.show()
