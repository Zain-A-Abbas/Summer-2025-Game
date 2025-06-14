class_name PlayerState
extends State

var player: Player

func _init(new_player: Player) -> void:
	player = new_player

func get_player_movement() -> Vector2:
	var move_vector = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	if move_vector.y != 0:
		move_vector.y *= 2.0
	
	return move_vector.rotated(deg_to_rad(31))
