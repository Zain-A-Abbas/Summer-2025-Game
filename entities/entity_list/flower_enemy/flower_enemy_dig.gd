class_name FlowerEnemyDig
extends EnemyState

const DIG_TIME: float = 0.5
const DIG_COOLDOWN: int = 15

var delta_count: float = 0.0
var cooldown_timer: int = 0
var dig_on_cooldown: bool = false
var direction: Vector3 = Vector3.ZERO

# temporary example
var dig_spots: Array[Vector3] = [Vector3(-7, 0, 7), Vector3(7, 0, 7), Vector3(-7, 0, -7)]

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	if dig_on_cooldown:
		cooldown_timer += 1
		#print(cooldown_timer)
		if cooldown_timer >= DIG_COOLDOWN:
			cooldown_timer = 0
			dig_on_cooldown = false

func st_physics_process(delta: float) -> void:
	if dig_on_cooldown:
		state_machine.change_state(&"Idle")
		return
	
	delta_count += delta
	
	if delta_count >= DIG_TIME:
		enemy.position = dig_spots.pick_random()
		direction = enemy.get_direction_to_player(enemy)
		enemy.face_direction(enemy, direction)
		state_machine.change_state(&"Idle")

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	dig_on_cooldown = true
