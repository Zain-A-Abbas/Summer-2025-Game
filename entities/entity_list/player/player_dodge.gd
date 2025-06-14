class_name PlayerDodge
extends PlayerState

const INVINCIBILITY_PERIOD: float = 0.7
const DODGE_TIME: float = 0.12

var dodge_speed: float = 2000.0
var delta_count: float = 0
var direction: Vector2 = Vector2.ZERO
var movement_vector: Vector3 = Vector3.ZERO

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0
	direction = get_player_movement()
	if direction == Vector2.ZERO:
		direction = Vector2(0, player.rotation.y)
	movement_vector = Vector3(-direction.x, 0, direction.y)
	
	player.hurtbox.invincibility_frames = true

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	player.hurtbox.invincibility_frames = false

func st_physics_process(delta: float) -> void:
	delta_count += delta

	if delta_count >= DODGE_TIME:
		state_machine.change_state(&"Idle")
		return
	
	player.velocity = movement_vector * dodge_speed * delta
	player.move_and_slide()
