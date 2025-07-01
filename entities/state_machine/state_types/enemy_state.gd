class_name EnemyState
extends State

var enemy: Enemy

func _init(new_enemy: Enemy) -> void:
	enemy = new_enemy

func distance_to_player() -> float:
	return enemy.position.distance_to(enemy.player.position)

func face_player():
	return enemy.position.direction_to(enemy.player.position)

func get_angle_to_face_player(dir: Vector3) -> float:
	return Vector2(dir.x, -dir.z).angle() + deg_to_rad(90)
