class_name PlayerDodge
extends PlayerState

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
	player.consume_stamina(player.DODGE_REQUIREMENT, 0.4)
	player.play_sound_fx(&"dodge_whoosh")

func st_physics_process(delta: float) -> void:
	delta_count += delta

	if delta_count >= player.dodge_duration:
		return state_machine.change_state(&"Idle")
	
	player.velocity = player.gravity_velocity() + movement_vector * player.dodge_speed
	player.velocity *= delta
	player.move_and_slide()
	
func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	player.hurtbox.invincibility_frames = false
