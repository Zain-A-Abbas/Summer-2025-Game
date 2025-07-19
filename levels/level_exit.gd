class_name LevelExit
extends Node3D

signal exit_chosen(next_level: LevelBase.LevelType)

const PAINTINGS: Dictionary[LevelBase.NormalLevels, Resource] = {
	LevelBase.NormalLevels.BRIDGE: preload("res://levels/paintings/bridge.png"),
	LevelBase.NormalLevels.CASTLE: preload("res://levels/paintings/castle.png"),
	LevelBase.NormalLevels.DINING: preload("res://levels/paintings/dining.png"),
	LevelBase.NormalLevels.SPIRE: preload("res://levels/paintings/spire.png"),
	LevelBase.NormalLevels.WATER: preload("res://levels/paintings/water.png")
	#&"Shop": preload("res://levels/paintings/shop.png"),
	#&"Healing": preload("res://levels/paintings/healing.png"),
	#&"Boss": preload("res://levels/paintings/boss.png"),
}

@export var always_active: bool = false

var normal_level_index: LevelBase.NormalLevels
var exit_type: LevelBase.LevelType
var active: bool = false

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var painting: Sprite3D = %PaintingTexture


func _ready() -> void:
	if always_active:
		activate()

func initialize(current_level: LevelBase, door_number: int):
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
		exit_type = LevelBase.LevelType.BOSS
	elif current_level.type == LevelBase.LevelType.BOSS:
		exit_type = LevelBase.LevelType.HEALING
	else:
		var level_roll: float = randf()
		#if level_roll > 0.90 && current_level.type != LevelBase.LevelType.SHOP:
		#	exit_type = LevelBase.LevelType.SHOP
		if level_roll > 0.85 && current_level.type != LevelBase.LevelType.HEALING && current_level.type != LevelBase.LevelType.SHOP:
			exit_type = LevelBase.LevelType.HEALING
		elif level_roll > 0.65:
			exit_type = LevelBase.LevelType.ELITE
			current_level.level_manager.choose_normal_level_index(door_number)
			normal_level_index = current_level.level_manager.new_level_index
		else:
			exit_type = LevelBase.LevelType.NORMAL
			current_level.level_manager.choose_normal_level_index(door_number)
			normal_level_index = current_level.level_manager.new_level_index
	select_painting(current_level)
	print("Exit: ", exit_type, " ", normal_level_index)	

func activate():
	active = true
	animation_player.play("open")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if !active:
		return
	
	if body is Player:
		exit_chosen.emit(exit_type, normal_level_index)
	else:
		push_error("Non-player triggered LevelExit collision")

func select_painting(current_level: LevelBase):
	if exit_type == LevelBase.LevelType.NORMAL || exit_type == LevelBase.LevelType.ELITE:
		painting.texture = current_level.level_manager.normal_level_paintings[normal_level_index]
	else:
		painting.texture = PlaceholderTexture2D.new()
