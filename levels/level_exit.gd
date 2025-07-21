class_name LevelExit
extends Node3D

signal exit_chosen(next_level: LevelBase.LevelType, new_normal_level_type: LevelManager.NormalLevelType)

enum PaintingType{
	BRIDGE,
	CASTLE,
	DINING,
	SPIRE,
	WATER,
	SHOP,
	HEALING,
	BOSS
}

const HEALTH_BONUS: int = 8
const PAINTINGS: Dictionary[PaintingType, Resource] = {
	PaintingType.BRIDGE: preload("res://levels/paintings/bridge.png"),
	PaintingType.CASTLE: preload("res://levels/paintings/castle.png"),
	PaintingType.DINING: preload("res://levels/paintings/dining.png"),
	PaintingType.SPIRE: preload("res://levels/paintings/spire.png"),
	PaintingType.WATER: preload("res://levels/paintings/water.png"),
	PaintingType.SHOP: preload("res://levels/paintings/shop.png"),
	PaintingType.HEALING: preload("res://levels/paintings/healing.png"),
	PaintingType.BOSS: preload("res://levels/paintings/boss.png"),
}

@export var always_active: bool = false

var painting_type: PaintingType
var exit_type: LevelBase.LevelType
var normal_level_type: LevelManager.NormalLevelType = LevelManager.NormalLevelType.NONE
var active: bool = false

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var painting: Sprite3D = %PaintingTexture
@onready var border: CSGBox3D = %Border


func _ready() -> void:
	if always_active:
		activate()

func initialize(current_level: LevelBase):
	var level_number: int = current_level.level_manager.current_level_count + 1
	var shop_before_boss: bool = level_number % LevelBase.CREATE_BOSS_LEVEL_MODULO == 0
	var guaranteed_shop: bool = level_number % LevelBase.CREATE_SHOP_LEVEL_MODULO == 0
	
	var boss_after_shop: bool = current_level.type == LevelBase.LevelType.SHOP && (level_number - 1) % LevelBase.CREATE_BOSS_LEVEL_MODULO == 0
	var boss_after_battle: bool = current_level.type != LevelBase.LevelType.SHOP && level_number % LevelBase.CREATE_BOSS_LEVEL_MODULO == 0
	
	if current_level.type != LevelBase.LevelType.SHOP && (shop_before_boss || guaranteed_shop) && !current_level.shop_exit_made:
		exit_type = LevelBase.LevelType.SHOP
		current_level.shop_exit_made = true
		painting_type = PaintingType.SHOP
	elif boss_after_shop || boss_after_battle:
		exit_type = LevelBase.LevelType.BOSS
		painting_type = PaintingType.BOSS
	elif current_level.type == LevelBase.LevelType.BOSS:
		exit_type = LevelBase.LevelType.HEALING
		painting_type = PaintingType.HEALING
	else:
		var level_roll: float = randf()
		#if level_roll > 0.90 && current_level.type != LevelBase.LevelType.SHOP:
		#	exit_type = LevelBase.LevelType.SHOP
		if !current_level.level_manager.healing_level_made && level_roll > 0.85 && current_level.type != LevelBase.LevelType.HEALING && current_level.type != LevelBase.LevelType.SHOP:
			exit_type = LevelBase.LevelType.HEALING
			painting_type = PaintingType.HEALING
			current_level.level_manager.healing_level_made = true
		elif level_roll > 0.65:
			exit_type = LevelBase.LevelType.ELITE
			border.material.albedo_color = Color.RED
			normal_level_type = current_level.level_manager.choose_normal_level_type()
		else:
			exit_type = LevelBase.LevelType.NORMAL
			normal_level_type = current_level.level_manager.choose_normal_level_type()
	select_painting(current_level)

func activate():
	active = true
	animation_player.play("open")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if !active:
		return
	
	if body is Player:
		exit_chosen.emit(exit_type, normal_level_type)
		body.heal(HEALTH_BONUS)
	else:
		push_error("Non-player triggered LevelExit collision")

func select_painting(current_level: LevelBase):
	if exit_type == LevelBase.LevelType.NORMAL || exit_type == LevelBase.LevelType.ELITE:
		painting.texture = PAINTINGS[normal_level_type]
	else:
		painting.texture = PAINTINGS[painting_type]
