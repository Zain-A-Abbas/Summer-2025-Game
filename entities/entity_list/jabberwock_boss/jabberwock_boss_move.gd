class_name JabberwockBossMove
extends EnemyState

var rage_component: JabberwockBossRageComponent
var delta_count: float = 0.0


func _init(new_enemy: Enemy, rage: JabberwockBossRageComponent) -> void:
	enemy = new_enemy
	rage_component = rage

func st_physics_process(delta: float) -> void:
	pass
