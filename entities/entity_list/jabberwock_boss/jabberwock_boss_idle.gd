class_name JabberwockBossIdle
extends EnemyState

var delta_count: float = 0.0
var cooldown: float = 0.0

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	cooldown = 0.0
	delta_count = 0.0

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	
