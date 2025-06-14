class_name EnemyWait
extends EnemyState

# In this function, the enemy just waits for a set amount of time before returning to idle

const DIRECTION_CHANGE_COOLDOWN: float = 0.15

var direction_change_timer: float = 0.0

# Movement speed during wait
var wait_speed: float = 40.0

var wait_time: float = 0.0
var wait_timer: float = 0.0

var direction: Vector3 = Vector3.ZERO


# If false, move in random directions. If true, circle around the player
var encircle: bool = false 

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	direction_change_timer = 0.0
	
	wait_timer = 0.0
	wait_time = args["time"]
	if args.has("wait_speed"):
		wait_speed = args["wait_speed"]
	
	encircle = false
	if args.has("encircle"):
		encircle = args["encircle"]

func st_physics_process(delta: float) -> void:
	pass
	wait_timer += delta
	direction_change_timer += delta
	
	if direction_change_timer >  DIRECTION_CHANGE_COOLDOWN:
		set_direction()
		direction_change_timer = 0.0
	
	enemy.velocity = direction * wait_speed * delta
	enemy.move_and_slide()
	
	if wait_timer > wait_time:
		state_machine.change_state(&"Idle")

func set_direction():
	if !encircle:
		direction = Vector3.FORWARD.rotated(Vector3.UP, randf_range(0.0, 4 * PI))
		enemy.look_at(enemy.player.position)
