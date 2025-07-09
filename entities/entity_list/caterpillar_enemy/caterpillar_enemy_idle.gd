class_name CaterpillarEnemyIdle
extends EnemyState

func st_physics_process(delta: float) -> void:
	if enemy.paralysis_effect(delta):
		return
	
	state_machine.change_state(&"Crawl")
