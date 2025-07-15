class_name LevelExit
extends Node3D

signal exit_chosen(next_level: LevelBase.LevelType)

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var exit_type: LevelBase.LevelType
var active: bool = false

@export var always_active: bool = false

func _ready() -> void:
	if always_active:
		activate()

func initialize(current_level: LevelBase):
	var level_number: int = current_level.level_manager.current_level_count + 1
	var shop_before_boss: bool = level_number % LevelBase.CREATE_BOSS_LEVEL_MODULO == 0
	var guaranteed_shop: bool = level_number % LevelBase.CREATE_SHOP_LEVEL_MODULO == 0
	
	var boss_after_shop: bool = current_level.type == LevelBase.LevelType.SHOP && (level_number - 1) % LevelBase.CREATE_BOSS_LEVEL_MODULO == 0
	var boss_after_battle: bool = current_level.type != LevelBase.LevelType.SHOP && level_number % LevelBase.CREATE_BOSS_LEVEL_MODULO == 0
	
	#print("shop_before_boss:", shop_before_boss)
	#print("guaranteed_shop:", guaranteed_shop)
	if current_level.type != LevelBase.LevelType.SHOP && (shop_before_boss || guaranteed_shop) && !current_level.shop_exit_made:
		#print("here")
		exit_type = LevelBase.LevelType.SHOP
		current_level.shop_exit_made = true
	elif boss_after_shop || boss_after_battle:
		exit_type = LevelBase.LevelType.BOSS # CHANGE LATER
	else:
		var level_roll: float = randf()
		#if level_roll > 0.90 && current_level.type != LevelBase.LevelType.SHOP:
		#	exit_type = LevelBase.LevelType.SHOP
		if level_roll > 0.85 && current_level.type != LevelBase.LevelType.HEALING && current_level.type != LevelBase.LevelType.SHOP:
			exit_type = LevelBase.LevelType.HEALING
		elif level_roll > 0.65:
			exit_type = LevelBase.LevelType.ELITE
		else:
			exit_type = LevelBase.LevelType.NORMAL
	#print("Exit: ", exit_type)	

func activate():
	active = true
	animation_player.play("open")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if !active:
		return
	
	if body is Player:
		exit_chosen.emit(exit_type)
	else:
		push_error("Non-player triggered LevelExit collision")
