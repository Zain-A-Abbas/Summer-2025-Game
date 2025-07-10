class_name FlowerEnemyIdle
extends EnemyState

var from_dig: bool = false
var dig_on_cooldown: bool = false
var distance: float = 0.0


func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	if args.has("from_dig"):
		from_dig = true
	elif args.has("dig_on_cooldown"):
		from_dig = args["dig_on_cooldown"]
	
	if !from_dig:
		enemy.dig_timer = 0.0
	enemy.action_animator.play("flower/idle")

func st_physics_process(delta: float) -> void:
	distance = distance_to_player()
	enemy.dig_timer += delta
	
	dig_on_cooldown = from_dig && enemy.dig_timer < enemy.dig_cooldown
	
	if !dig_on_cooldown && distance < enemy.attack_range[0]: # dig away if player is close
		return state_machine.change_state(&"Dig")
	
	if distance <= enemy.attack_range[1]:
		return state_machine.change_state(&"Shoot", {"dig_on_cooldown": dig_on_cooldown})
