class_name MouseEnemyJump
extends EnemyState

const JUMP_TIME: float = 0.5

var delta_count: float = 0.0
var cooldown_timer: int = 0
var direction: Vector3 = Vector3.ZERO

# temporary example
var jump_spots: Array[Vector3] = [Vector3(-7, 0, 7), Vector3(7, 0, 7), Vector3(-7, 0, -7)]

func _init(new_enemy: Enemy) -> void:
	enemy = new_enemy

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	if delta_count >= JUMP_TIME:
		enemy.position = jump_spots.pick_random()
		state_machine.change_state(&"Idle")

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	false
