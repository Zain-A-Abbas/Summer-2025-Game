extends LevelCamera
class_name SpireLevelCamera

func _physics_process(delta: float) -> void:
	super(delta)
	var height_value: float = (wrapf(player.position.y, 0, 22.5)) / (22.5)
	
	rotation.y = deg_to_rad(ROTATION.y + 360.0 * height_value)
	
	offset_vector = OFFSET_VECTOR.rotated(
		Vector3.UP,
		2 * PI * height_value
		)
