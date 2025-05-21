class_name PlayerState
extends State

var player: Player

func _init(new_player: Player) -> void:
	player = new_player

func get_player_movement() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
