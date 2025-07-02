class_name FlowerEnemyDig
extends EnemyState

const DIG_TIME: float = 0.5
const DIG_COOLDOWN: int = 15

var delta_count: float = 0.0
var cooldown_timer: int = 0
var dig_on_cooldown: bool = false
var dig_positions: Node3D
var dig_spot_index: int

func _init(new_enemy: Enemy, dig_spots: Node3D) -> void:
	enemy = new_enemy
	dig_positions = dig_spots

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	if dig_on_cooldown:
		cooldown_timer += 1
		#print(cooldown_timer)
		if cooldown_timer >= DIG_COOLDOWN:
			cooldown_timer = 0
			dig_on_cooldown = false
	
	# get new dig position index
	dig_spot_index = randi_range(0, dig_positions.get_child_count() - 1)

func st_physics_process(delta: float) -> void:
	if dig_on_cooldown:
		state_machine.change_state(&"Idle")
		return
	
	delta_count += delta
	
	if delta_count >= DIG_TIME:
		enemy.position = dig_positions.get_child(dig_spot_index).position
		state_machine.change_state(&"Idle")

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	dig_on_cooldown = true
