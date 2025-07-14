class_name LevelBase
extends Node3D

signal level_completed(level: LevelBase, next_level: LevelType)

enum LevelType {
	NORMAL,
	ELITE,
	SHOP,
	HEALING,
	BOSS
}

const MONEY_PICKUP = preload("res://levels/pickups/money_pickup.tscn")
const BASIC_ENEMY = preload("res://entities/entity_list/basic_enemy/basic_enemy.tscn")
const FLOWER_ENEMY = preload("res://entities/entity_list/flower_enemy/flower_enemy.tscn")
const MOUSE_ENEMY = preload("res://entities/entity_list/mouse_enemy/mouse_enemy.tscn")
const CATERPILLAR_ENEMY = preload("res://entities/entity_list/caterpillar_enemy/caterpillar_enemy.tscn")
const MAD_HATTER_ENEMY = preload("res://entities/entity_list/mad_hatter_enemy/mad_hatter_enemy.tscn")
const RED_KNIGHT_ENEMY = preload("res://entities/entity_list/red_knight_enemy/red_knight_enemy.tscn")
const JABBERWOCK_ENEMY = preload("res://entities/entity_list/jabberwock_boss/jabberwock_boss.tscn")

const CREATE_SHOP_LEVEL_MODULO: int = 2
const CREATE_BOSS_LEVEL_MODULO: int = 5

@export var has_enemies: bool = true
@export var enemy_minimum: int = 2
@export var enemy_limit: int = 3
@export var enemy_spawn_limits: Dictionary[StringName, int] = {
	&"BASIC": 0,
	&"CATERPILLAR": 0,
	&"FLOWER": 0,
	&"MAD_HATTER": 0,
	&"MOUSE": 0,
	&"RED_KNIGHT": 0
}

var enemy_count: int = 0
var enemies_killed: int = 0
var level_manager: LevelManager
var type: LevelType
var enemy_spawn_count: Dictionary[StringName, int] = {
	&"BASIC": 0,
	&"CATERPILLAR": 0,
	&"FLOWER": 0,
	&"MAD_HATTER": 0,
	&"MOUSE": 0,
	&"RED_KNIGHT": 0
}
var enemy_spawn_list: Array[StringName]
var shop_exit_made: bool = false

@onready var static_geometry: Node3D = %StaticGeometry
@onready var dynamic_geometry: Node3D = %DynamicGeometry
@onready var enemies: Node3D = %Enemies
@onready var lighting: Node3D = %Lighting
@onready var world_environment: WorldEnvironment = %WorldEnvironment
@onready var level_camera: Camera3D = %LevelCamera
@onready var enemy_positions: Node3D = %EnemyPositions
@onready var player: Player = %Player
@onready var enemy_data: Node3D = %EnemyData
@onready var projectiles: Node3D = %Projectiles
@onready var sounds: Node3D = %Sounds

func setup_level(_level_manager: LevelManager, _type: LevelType, enemy_spawn_count: int):
	level_manager = _level_manager 
	type = _type
	level_camera.initialize(player)
	enemy_spawn_list = initialize_enemy_list()
	shop_exit_made = false
	
	if _type == LevelType.BOSS:
		var boss: Enemy = JABBERWOCK_ENEMY.instantiate()
		enemies.add_child(boss)
		boss.initialize_enemy(player, enemy_data, enemy_positions, enemies, projectiles)
		boss.position = enemy_positions.get_child(0).global_position
		boss.enemy_killed.connect(enemy_kill)
		
		enemy_count += 1
		
	else:
		for n in enemy_spawn_count:
			if n > enemy_positions.get_child_count():
				push_error("More enemies provided to a level than it has positions for.")
				break
			
			if enemy_spawn_list.size() == 0:
				break
			
			var new_enemy_index = randi_range(0, enemy_spawn_list.size() - 1)
			var new_enemy_type: StringName = enemy_spawn_list[new_enemy_index]
			update_enemy_spawn_counts(new_enemy_type, 1)
			
			if !can_enemy_spawn_type(new_enemy_type):
				update_enemy_spawn_counts(new_enemy_type, -1)
				enemy_spawn_list.pop_at(new_enemy_index)
				if n > 0:
					n -= 1
					
				continue
			
			var new_enemy: Enemy = spawn_enemy(new_enemy_type)
			
			enemies.add_child(new_enemy)
			new_enemy.position = enemy_positions.get_child(n).global_position
			new_enemy.initialize_enemy(player, enemy_data, enemy_positions, enemies, projectiles)
			new_enemy.enemy_killed.connect(enemy_kill)
			
			enemy_count += 1
			
	#print(enemy_count)
	for exit in get_level_exits():
		exit.initialize(self)
		exit.exit_chosen.connect(exit_choose)

func start_level(_type: LevelType):
	for enemy in enemies.get_children():
		if enemy is Enemy:
			enemy.activate_enemy()
		else:
			push_warning("Non-enemy found as child in Enemies node in level scene")
	
	"""
	if _type == LevelType.NORMAL:
		Bgm.play_bgm(Bgm.BGM_TYPE.BATTLE, 1.0)
	elif _type == LevelType.SHOP:
		Bgm.play_bgm(Bgm.BGM_TYPE.SHOP, 1.0)
	elif _type == LevelType.HEALING:
		Bgm.play_bgm(Bgm.BGM_TYPE.HEALING, 1.0)
	elif _type == LevelType.BOSS:
		Bgm.play_bgm(Bgm.BGM_TYPE.BOSS, 1.0)
	"""
	
func enemy_kill(enemy: Enemy):
	enemies_killed += 1
	
	var enemy_position: Vector3 = enemy.global_position
	var money_pickup: MoneyPickup = MONEY_PICKUP.instantiate()
	add_child(money_pickup)
	money_pickup.position = enemy_position + Vector3(0.0, 1.0 * randf(), 0.0)
	
	if enemies_killed == enemy_count:
		var index: int = 1
		
		for exit in get_level_exits():
			exit.activate()
			sounds.get_node("door_open_%d" % index).play()
			index += 1

func exit_choose(exit_type: LevelType):
	level_completed.emit(self, exit_type)

func get_level_exits() -> Array[LevelExit]:
	var exits: Array[LevelExit] = []
	
	for exit in get_tree().get_nodes_in_group("level_exits"):
		if exit is LevelExit:
			exits.append(exit)
		else:
			push_error("Non-levelexit found in level_exits group")
	
	return exits

func initialize_enemy_list() -> Array[StringName]:
	var list: Array[StringName] = []
	
	for type in enemy_spawn_limits.keys():
		if enemy_spawn_limits[type] > 0:
			list.append(type)
	
	return list
	
func spawn_enemy(type: StringName) -> Enemy:
	if type == &"BASIC":
		return BASIC_ENEMY.instantiate()
	elif type == &"CATERPILLAR":
		return CATERPILLAR_ENEMY.instantiate()
	elif type == &"MAD_HATTER":
		return MAD_HATTER_ENEMY.instantiate()
	elif type == &"FLOWER":
		return FLOWER_ENEMY.instantiate()
	elif type == &"MOUSE":
		return MOUSE_ENEMY.instantiate()
	else:
		return RED_KNIGHT_ENEMY.instantiate()

func can_enemy_spawn_type(type: StringName) -> bool:
	return enemy_spawn_count[type] <= enemy_spawn_limits[type]

func update_enemy_spawn_counts(type: StringName, change: int):
	enemy_spawn_count[type] += change
