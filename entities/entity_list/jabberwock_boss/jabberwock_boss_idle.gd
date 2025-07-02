class_name JabberwockBossIdle
extends EnemyState

const ACTION_LIST: Array[StringName] = [&"Sweep", &"Swipe"]

var rage_component: JabberwockBossRageComponent
var delta_count: float = 0.0
var cooldown: float = 0.0
var direction: Vector3
var next_action_time: float = 0.0

func _init(new_enemy: Enemy, rage: JabberwockBossRageComponent) -> void:
	enemy = new_enemy
	rage_component = rage
	direction = face_player()
	enemy.rotation.y = get_angle_to_face_player(direction)

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	cooldown = 0.0
	delta_count = 0.0
	
	if args.has(&"cooldown"):
		cooldown = args['cooldown']
		
	next_action_time = randf_range(0.8, 2.0) + cooldown

func st_physics_process(delta: float) -> void:
	delta_count += delta
	rage_component.decrease_rage(delta)
	
	if delta_count >= next_action_time:
		state_machine.change_state(&"Swipe")
