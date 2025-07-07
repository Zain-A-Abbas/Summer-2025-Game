class_name FlowerEnemyIdle
extends EnemyState

var from_dig: bool = false
var dig_on_cooldown: bool = false
var delta_count: float = 0.0
var distance: float = 0.0


func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	if !args.has("from_shoot"):
		delta_count = 0.0
	from_dig = args.has("from_dig")

func st_physics_process(delta: float) -> void:
	distance = distance_to_player()
	delta_count += delta_count
	
	dig_on_cooldown = from_dig && delta_count < enemy.dig_cooldown
	
	if !dig_on_cooldown && distance < enemy.attack_range[0]: # dig away if player is close
		return state_machine.change_state(&"Dig")
	
	if distance <= enemy.attack_range[1]:
		return state_machine.change_state(&"Shoot")
