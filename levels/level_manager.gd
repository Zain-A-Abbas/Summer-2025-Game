class_name LevelManager
extends Node

# Manages switching betweens levels and also contains run-specific data

enum NormalLevelType {
	BRIDGE,
	CASTLE,
	DINING,
	SPIRE,
	WATER,
	NONE
}

const ENEMY_DMG_MULTIPLIER_INC: float = 0.12
const ENEMY_HP_MULTIPLIER_INC: float = 0.2
const NORMAL_LEVELS: Dictionary[NormalLevelType, PackedScene] = {
	NormalLevelType.BRIDGE: preload("res://levels/level_list/bridge_level/bridge_level.tscn"),
	NormalLevelType.CASTLE: preload("res://levels/level_list/castle_level/castle_level.tscn"),
	NormalLevelType.DINING: preload("res://levels/level_list/dining_room/dining_room_level.tscn"),
	NormalLevelType.SPIRE: preload("res://levels/level_list/spire_level/spire_level.tscn"),
	NormalLevelType.WATER: preload("res://levels/level_list/water_level/water_level.tscn"),
}

@export var use_test_level: bool = false
@export var test_level: PackedScene
@export var normal_levels: Array[NormalLevelType] = []
@export var elite_levels: Array[PackedScene] = []
@export var healing_level: PackedScene
@export var shop_level: PackedScene
@export var boss_level: PackedScene

var current_level_type: LevelBase.LevelType = LevelBase.LevelType.NONE
var current_level_count: int = 0
var new_normal_level_type: NormalLevelType = NormalLevelType.NONE
var normal_level_queue: Array[NormalLevelType]
var bosses_killed: int = 0
var money: int = 300
var current_player: Player
var player_upgrades: PlayerUpgrades
var prev_hp: int = -1
var enemy_scaler: EnemyScaler
var run_scale_enemies: bool = false
var enemy_dmg_multiplier: float = 1.0
var enemy_hp_multiplier: float = 1.0

@onready var level_holder: Node3D = %LevelHolder
@onready var fade: ColorRect = %Fade
@onready var player_ui: PlayerUI = %PlayerUI

var level_queue: Array[int] = []

# PAUSE LOGIC
var paused: bool = false

func _ready() -> void:
	if get_tree().root.get_children().has(self):
		begin_run()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if level_holder.get_child_count() == 0:
			return
		if paused:
			print("hagiythdfkytdfhg")
			level_holder.process_mode = Node.PROCESS_MODE_INHERIT
			Bgm.change_volume(1.0)
		else:
			print("hgagh")
			level_holder.process_mode = Node.PROCESS_MODE_DISABLED
			Bgm.change_volume(0.3)
		paused = !paused
		player_ui.pause(paused)

func begin_run():
	RunStats.reset()
	player_upgrades = PlayerUpgrades.new()
	player_upgrades.upgrades_updated.connect(update_upgrade_ui)
	current_level_count = 1
	player_ui.visible = true
	enemy_scaler = EnemyScaler.new(self)
	
	normal_level_queue = normal_levels.duplicate(true)
	new_normal_level_type = choose_normal_level_type()
	
	await fade_transition(true)
	create_level()

func create_level(new_level_type: LevelBase.LevelType = LevelBase.LevelType.NORMAL, old_level_type: LevelBase.LevelType = LevelBase.LevelType.NONE):
	var new_level: LevelBase
	if use_test_level:
		new_level = test_level.instantiate()
	elif new_level_type == LevelBase.LevelType.NORMAL:
		new_level = get_normal_level()
	elif new_level_type == LevelBase.LevelType.ELITE:
		if elite_levels.is_empty():
			new_level = get_normal_level()
		else:
			new_level = elite_levels.pick_random().instantiate()
	elif new_level_type == LevelBase.LevelType.HEALING:
		new_level = healing_level.instantiate()
	elif new_level_type == LevelBase.LevelType.SHOP:
		new_level = shop_level.instantiate()
	elif new_level_type == LevelBase.LevelType.BOSS:
		new_level = boss_level.instantiate()
	
	current_level_type = new_level_type
	
	level_holder.add_child(new_level)
	var enemy_count: int = randi_range(new_level.enemy_minimum, new_level.enemy_limit)
	if new_level_type == LevelBase.LevelType.ELITE:
		enemy_count = new_level.enemy_limit
	if !new_level.has_enemies:
		enemy_count = 0

	new_level.setup_level(self, new_level_type, enemy_count)
	player_ui.setup_level(new_level)
	new_level.level_completed.connect(level_complete)
	
	current_player = new_level.player
	if !current_player:
		push_error("No player found in refresh_player()")
		return
	
	current_player.initialize_upgrades(player_upgrades)
	if prev_hp == -1:
		current_player.health_component.current_health = current_player.health_component.max_health
	else:
		current_player.health_component.current_health = prev_hp
	
	current_player.obtained_money.connect(money_gain)
	player_ui.refresh_player(current_player)
	
	await fade_transition(false)
	new_level.start_level(new_level_type)

func level_complete(level: LevelBase, exit_type: LevelBase.LevelType, normal_level_type: LevelManager.NormalLevelType):
	await fade_transition(true)
	
	prev_hp = current_player.health_component.current_health
	
	if level.type != LevelBase.LevelType.SHOP && level.type != LevelBase.LevelType.HEALING:
		current_level_count += 1

	if level.type == LevelBase.LevelType.BOSS:
		bosses_killed += 1
		player_upgrades.increase_upgrade_limits()
		enemy_dmg_multiplier += ENEMY_DMG_MULTIPLIER_INC
		enemy_hp_multiplier += ENEMY_HP_MULTIPLIER_INC
		run_scale_enemies = true
		#print("scaling turned on")
	
	reset_normal_level_queue()
	if level.type == LevelBase.LevelType.NORMAL:
		normal_level_queue.erase(normal_level_type)
	
	level.queue_free()
	
	await get_tree().process_frame
	
	new_normal_level_type = normal_level_type
	create_level(exit_type)

func update_upgrade_ui():
	current_player.initialize_upgrades(player_upgrades)
	player_ui.update_upgrades(current_player)

func money_gain(amount: int):
	RunStats.money_earned += amount
	money = money + amount
	player_ui.update_money(money)

func fade_transition(out: bool):
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	if out:
		fade.modulate.a = 0.0
		fade.visible = true
		tween.tween_property(fade, "modulate:a", 1.0, 0.3)
		await tween.finished
	else:
		fade.modulate.a = 1.0
		tween.tween_property(fade, "modulate:a", 0.0, 0.3)
		await tween.finished
		fade.visible = false

func choose_normal_level_type() -> NormalLevelType:
	return normal_level_queue.pop_at(randi_range(0, normal_level_queue.size() - 1))

func get_normal_level() -> LevelBase:
	var new_level: PackedScene = NORMAL_LEVELS[new_normal_level_type]
	return new_level.instantiate()

func reset_normal_level_queue():
	normal_level_queue = normal_levels.duplicate(true)
