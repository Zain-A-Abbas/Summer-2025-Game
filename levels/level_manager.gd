class_name LevelManager
extends Node

# Manages switching betweens levels and also contains run-specific data

const ENEMY_DMG_MULTIPLIER_INC: float = 0.15
const ENEMY_HP_MULTIPLIER_INC: float = 0.2

@export var endless: bool = false
@export var max_levels: int = 10
@export var normal_levels: Array[PackedScene] = []
@export var elite_levels: Array[PackedScene] = []
@export var healing_level: PackedScene
@export var shop_level: PackedScene
@export var boss_level: PackedScene

var current_level: PackedScene = null
var current_level_type: LevelBase.LevelType
var current_level_count: int = 0
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


func _ready() -> void:
	if get_tree().root.get_children().has(self):
		begin_run()

func begin_run():
	player_upgrades = PlayerUpgrades.new()
	player_upgrades.upgrades_updated.connect(update_upgrade_ui)
	current_level_count = 1
	player_ui.visible = true
	enemy_scaler = EnemyScaler.new()
	await fade_transition(true)
	create_level(LevelBase.LevelType.BOSS)

func create_level(new_level_type: LevelBase.LevelType = LevelBase.LevelType.NORMAL):
	var new_level: LevelBase	
	if new_level_type == LevelBase.LevelType.NORMAL:
		new_level = choose_normal_level()
	elif new_level_type == LevelBase.LevelType.ELITE:
		if elite_levels.is_empty():
			new_level = choose_normal_level()
		else:
			new_level = elite_levels.pick_random().instantiate()
	elif new_level_type == LevelBase.LevelType.HEALING:
		new_level = healing_level.instantiate()
	elif new_level_type == LevelBase.LevelType.SHOP:
		new_level = shop_level.instantiate()
	elif new_level_type == LevelBase.LevelType.BOSS:
		new_level = boss_level.instantiate()
	
	level_holder.add_child(new_level)
	var enemy_count: int = randi_range(new_level.enemy_minimum, new_level.enemy_limit)
	if !new_level.has_enemies:
		enemy_count = 0
	#print("Level: ", current_level_count, " ", new_level_type)
	new_level.setup_level(self, new_level_type, enemy_count)
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
	current_level_type = new_level_type
	new_level.start_level(new_level_type)

func level_complete(level: LevelBase, exit_type: LevelBase.LevelType):
	await fade_transition(true)
	
	prev_hp = current_player.health_component.current_health
	
	if level.type != LevelBase.LevelType.SHOP && level.type != LevelBase.LevelType.HEALING:
		current_level_count += 1

	#if current_level_type == LevelBase.LevelType.BOSS && endless:
	player_upgrades.increase_upgrade_limits()
	enemy_dmg_multiplier += ENEMY_DMG_MULTIPLIER_INC
	enemy_hp_multiplier += ENEMY_HP_MULTIPLIER_INC
	run_scale_enemies = true

	level.queue_free()
	
	await get_tree().process_frame
	
	if !endless && current_level_count == max_levels:
		return # game complete here
	
	create_level(exit_type)

func update_upgrade_ui():
	current_player.initialize_upgrades(player_upgrades)
	player_ui.update_upgrades(current_player)

func money_gain(amount: int):
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

func choose_normal_level() -> LevelBase:
	if normal_levels.size() > 1 || (normal_levels.size() == 1 && current_level != null):
		# choose from filtered pool
		var new_level: PackedScene = normal_levels.pop_at(randi_range(0, normal_levels.size() - 1))
		
		# reinsert old level
		if current_level_count > 1:
			normal_levels.append(current_level)
	
		current_level = new_level
		return current_level.instantiate()
	else:
		return normal_levels[0].instantiate()
