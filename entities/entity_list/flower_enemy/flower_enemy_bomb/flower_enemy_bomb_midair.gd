class_name FlowerEnemyBombMidair
extends ProjectileState

var delta_count: float = 0.0
var direction: Vector3 = Vector3.ZERO
var return_position: Vector3 = Vector3.ZERO

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0
	proj.show()
	if args.has("dir"):
		direction = args["dir"]
	if args.has("return"):
		return_position = args["return"]

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	if delta_count > 0.5:
		state_machine.change_state(&"Explode")
		return
	
	proj.velocity = direction * 550 * delta
	proj.move_and_slide()

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	proj.hide()
	proj.position = return_position
