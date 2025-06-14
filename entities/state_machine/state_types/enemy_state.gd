class_name EnemyState
extends State

var enemy: Enemy

func _init(new_enemy: Enemy) -> void:
	enemy = new_enemy

func distance_to_player() -> float:
	return enemy.position.distance_to(enemy.player.position)

func face_player():
	return enemy.position.direction_to(enemy.player.position)
