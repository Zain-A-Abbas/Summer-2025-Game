class_name JabberwockBossShoot
extends EnemyState

const BOMB = preload("res://entities/entity_list/flower_enemy/flower_enemy_bomb/flower_enemy_bomb.tscn")
const SEED = preload("res://entities/entity_list/caterpillar_enemy/caterpillar_enemy_seed/caterpillar_enemy_seed.tscn")
const ACTION_LIST: Array[StringName] = [&"Bomb", &"Seed", &"Breath"]
const ACTION_COOLDOWNS: Array[float] = [0.8, 1.2, 3.0]
#const ACTION_RAGE_THRESHOLD: Array[int] = [0, 100, 200]

var action: StringName
var action_index: int

var rage_component: JabberwockBossRageComponent
var breath: AttackObject
var delta_count: float = 0.0


func _init(new_enemy: Enemy, rage: JabberwockBossRageComponent, atk: AttackObject) -> void:
	enemy = new_enemy
	rage_component = rage
	breath = atk

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	
	action_index = randi_range(0, 2)
	action = ACTION_LIST[action_index]

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	if action == &"Bomb":
		pass
	elif action == &"Seed":
		pass
	else: # breath
		state_machine.change_state(&"Idle", {"cooldown": ACTION_COOLDOWNS[action_index]})
