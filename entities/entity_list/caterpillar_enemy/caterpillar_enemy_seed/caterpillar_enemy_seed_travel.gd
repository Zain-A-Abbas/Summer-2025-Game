class_name CaterpillarEnemySeedTravel
extends ProjectileState

const TTL: float = 1.1

var delta_count: float = 0.0
var direction: Vector3

func _init(new_seed: CaterpillarEnemySeed, dir: Vector3) -> void:
	proj = new_seed
	direction = dir

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0

func st_physics_process(delta: float) -> void:
	delta_count += delta

	if delta_count >= TTL:
		state_machine.change_state(&"Explode")
		return

	proj.velocity = direction * proj.movement_component.move_speed * delta
	proj.move_and_slide()

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	pass
