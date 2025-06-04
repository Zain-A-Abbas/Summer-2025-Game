class_name PlayerDodge
extends PlayerState

var dodge_speed: float = 2000.0
var delta_count: float = 0
var direction: Vector2 = Vector2.ZERO
var movement_vector: Vector3 = Vector3.ZERO
const DODGE_TIME: float = 0.12

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0
	direction = get_player_movement()
	if direction == Vector2.ZERO:
		direction = Vector2(1, 0).rotated(deg_to_rad(31))
	movement_vector = Vector3(-direction.x, 0, direction.y)

func st_physics_process(delta: float) -> void:
	delta_count += delta

	if delta_count >= DODGE_TIME:
		state_machine.change_state(&"Idle")
		return
	
	player.velocity = movement_vector * dodge_speed * delta
	player.move_and_slide()
