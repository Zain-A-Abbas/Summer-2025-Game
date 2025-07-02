class_name CaterpillarEnemyIdle
extends EnemyState

func st_physics_process(delta: float) -> void:
	state_machine.change_state(&"Crawl")
