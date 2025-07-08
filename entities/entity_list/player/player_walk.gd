class_name PlayerWalk
extends PlayerState

const STEP_TIME: float = 0.3

var delta_count: float = 0.0
var step_index: int = 1


func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	step_index = 2
	
	player.play_sound_fx(player.sounds, &"run_step_1")
	player.action_animator.play("walk")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	if Input.is_action_just_pressed("attack"):
		return state_machine.change_state(&"Attack")
	
	var movement_input: Vector2 = get_player_movement()
	if movement_input == Vector2.ZERO: # if no movement register, go back to idle state
		return state_machine.change_state(&"Idle")

	if Input.is_action_just_pressed("dodge") && player.can_dodge():
		return state_machine.change_state(&"Dodge")

	var movement_vector: Vector3 = Vector3(-movement_input.x, 0.0, movement_input.y)

	player.velocity = player.gravity_velocity() + movement_vector * player.movement_component.move_speed
	player.velocity *= delta
	player.rotation.y = Vector2(-movement_vector.x, movement_vector.z).angle() + deg_to_rad(90)
	player.move_and_slide()
	
	# play footstep sound fx
	if delta_count > STEP_TIME:
		player.play_sound_fx(player.sounds, "run_step_%d" % step_index)
		step_index += 1
		
		delta_count = 0.0
		if step_index > 5:
			step_index = 1
