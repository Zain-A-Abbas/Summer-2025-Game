extends LevelBase
class_name ShopLevel

func start_level(_type: LevelType):
	super(_type)
	for child in dynamic_geometry.get_children():
		if child is ShopItem:
			child.initialize(level_manager)
