class_name JabberwockBossIdle
extends EnemyState

const MELEE_DISTANCE: float = 8.5

var rage_component: JabberwockBossRageComponent
var delta_count: float = 0.0
var cooldown: float = 0.0
var next_action_time: float = 0.0

var direction_to_player: Vector3
var forward_direction: Vector3


func _init(new_enemy: Enemy, rage: JabberwockBossRageComponent) -> void:
	enemy = new_enemy
	rage_component = rage
	
	enemy.face_direction(face_player())

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	cooldown = 0.0
	delta_count = 0.0
	
	if args.has(&"cooldown"):
		cooldown = args['cooldown']
		
	next_action_time = randf_range(0.8, 2.0) + cooldown 
	#enemy.action_animator.play("jabberwock/idle")

func st_physics_process(delta: float) -> void:
	
	delta_count += delta
	rage_component.decay_rage(delta)
	
	if enemy.paralysis_effect(delta):
		return
	
	direction_to_player = face_player()
	forward_direction = enemy.global_transform.basis.z
	
	#print(distance_to_player())
	if delta_count >= next_action_time:
		if distance_to_player() < MELEE_DISTANCE:
			if forward_direction.dot(direction_to_player) >= -0.2:
				return state_machine.change_state(&"Swipe")
				#print("in front", forward_direction.dot(direction_to_player))
			elif forward_direction.dot(direction_to_player) < -0.2:
				return state_machine.change_state(&"Sweep")
				#print("behind", forward_direction.dot(direction_to_player))
		return state_machine.change_state(&"Shoot")
