extends LevelBase
class_name ShopLevel

func start_level(_type: LevelType, old_level_type: LevelBase.LevelType):
	super(_type, old_level_type)
	for child in dynamic_geometry.get_children():
		if child is ShopItem:
			child.initialize(level_manager)
