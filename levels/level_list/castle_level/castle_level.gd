extends LevelBase
class_name CastleLevel

@onready var directional_light_3d: DirectionalLight3D = %DirectionalLight3D

@export var y_rotation: float = 45.0

func setup_level(_level_manager: LevelManager, _type: LevelType, enemy_spawn_count: int):
	var radians_rotation: float = deg_to_rad(y_rotation)
	static_geometry.rotate_y(radians_rotation)
	enemy_positions.rotate_y(radians_rotation)
	directional_light_3d.rotate_y(radians_rotation)
	sounds.rotate_y(radians_rotation)
	enemy_data.rotate_y(radians_rotation)
	
	super(_level_manager, _type, enemy_spawn_count)
