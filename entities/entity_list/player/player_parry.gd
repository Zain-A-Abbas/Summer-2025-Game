class_name PlayerParry
extends PlayerState

var invincibility_period: float
var dodge_speed: float = 2000.0
var delta_count: float = 0
var direction: Vector2 = Vector2.ZERO
var movement_vector: Vector3 = Vector3.ZERO
var parry_over: bool = false
var parry_succeeded: bool = false


func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0
	invincibility_period = player.base_parry_invincibility_period + player.upgrades.extra_parry_time * player.upgrades.PARRY_BONUS_AMOUNT
	parry_over = false
	direction = get_player_movement()
	if direction == Vector2.ZERO:
		direction = Vector2(0, player.rotation.y)
	movement_vector = Vector3(-direction.x, 0, direction.y)
	
	player.can_get_parry_point = true
	player.hurtbox.parry_frames = true
	player.consume_stamina(player.PARRY_REQUIREMENT, 0.2)
	
	player.animation_tree["parameters/ParryTimeSeek/seek_request"] = 0.23
	player.action_animator.play("parry")

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	player.can_get_parry_point = false
	player.hurtbox.parry_frames = false

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	if delta_count >= player.parry_duration:
		return state_machine.change_state(&"Idle")
	
	if delta_count >= invincibility_period && !parry_over:
		player.hurtbox.parry_frames = false
		parry_over = true
	
	player.velocity = player.gravity_velocity() * delta
	player.move_and_slide()
