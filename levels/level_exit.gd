class_name LevelExit
extends CSGBox3D

signal exit_chosen(next_level: LevelBase.LevelType)

@onready var open_indicator: CSGBox3D = %OpenIndicator

var exit_type: LevelBase.LevelType

var active: bool = false
@export var always_active: bool = false


func _ready() -> void:
	open_indicator.visible = false
	if always_active:
		activate()

func initialize(current_level: LevelBase):
	var level_number: int = current_level.level_manager.current_level
	if level_number == 10:
		exit_type = LevelBase.LevelType.BOSS
	elif level_number == 5:
		exit_type = LevelBase.LevelType.SHOP
	else:
		var level_roll: float = randf()
		if level_roll < 0.5:
			exit_type = LevelBase.LevelType.NORMAL
		elif level_roll < 0.65:
			exit_type = LevelBase.LevelType.ELITE
		elif level_roll < 0.90:
			if current_level.type == LevelBase.LevelType.HEALING:
				return initialize(current_level)
			exit_type = LevelBase.LevelType.HEALING
		else:
			if current_level.type == LevelBase.LevelType.SHOP:
				return initialize(current_level)
			exit_type = LevelBase.LevelType.SHOP
	
	if material is StandardMaterial3D:
		if exit_type == LevelBase.LevelType.HEALING:
			material.albedo_color = Color.GREEN
		elif exit_type == LevelBase.LevelType.SHOP:
			material.albedo_color = Color.YELLOW
		elif exit_type == LevelBase.LevelType.ELITE:
			material.albedo_color = Color.ORANGE
		elif exit_type == LevelBase.LevelType.BOSS:
			material.albedo_color = Color.BLACK

func activate():
	active = true
	
	open_indicator.visible = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if !active:
		return
	
	if body is Player:
		exit_chosen.emit(exit_type)
	else:
		push_error("Non-player triggered LevelExit collision")
