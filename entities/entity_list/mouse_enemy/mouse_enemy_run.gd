class_name MouseEnemyRun
extends EnemyState

const TIME_TO_JUMP: float = 1.0

var delta_count: float = 0
var direction: Vector3 = Vector3.ZERO
var distance_to_run: float = 0

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	face_player()
	direction = direction.normalized()
	direction = direction.rotated(Vector3(0,1,0), deg_to_rad(180))
	if args.has("DISTANCE_TO_RUN"):
		distance_to_run = args["DISTANCE_TO_RUN"]

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	face_player()
	direction = direction.normalized()
	direction = direction.rotated(Vector3(0,1,0), deg_to_rad(180))

	if delta_count > TIME_TO_JUMP:
		state_machine.change_state(&"Jump")
		return

	if distance_to_player() >= distance_to_run:
		state_machine.change_state(&"Idle")
		return

	enemy.velocity = direction * enemy.movement_component.move_speed * delta
	enemy.move_and_slide()

func face_player():
	direction = enemy.position.direction_to(enemy.player.position)
