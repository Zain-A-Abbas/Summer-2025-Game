class_name PlayerState
extends State

var player: Player

func _init(new_player: Player) -> void:
	player = new_player

func get_player_movement() -> Vector2:
	var move_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	
	var cam_rot: float = -135
	if player.camera:
		cam_rot = rad_to_deg(player.camera.rotation.y)
	move_vector = move_vector.rotated(deg_to_rad(cam_rot + 180))
	
	return move_vector
	
