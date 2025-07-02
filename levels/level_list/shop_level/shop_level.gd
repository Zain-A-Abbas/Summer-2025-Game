extends LevelBase
class_name ShopLevel

func start_level():
	super()
	for child in dynamic_geometry.get_children():
		if child is ShopItem:
			child.initialize(level_manager)
