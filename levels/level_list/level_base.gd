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

@export var has_enemies: bool = true
@export var enemy_minimum: int = 2
@export var enemy_limit: int = 3
@export var enemy_spawn_limits: Dictionary[String, int] = {
	"BASIC": 0,
	"CATERPILLAR": 0,
	"MAD_HATTER": 0,
	"FLOWER": 0,
	"MOUSE": 0,
	"RED_KNIGHT": 0
}

var enemy_count: int = 0
var enemies_killed: int = 0
var level_manager: LevelManager
var type: LevelType
var enemy_spawn_count: Dictionary[String, int] = {
	"BASIC": 0,
	"CATERPILLAR": 0,
	"MAD_HATTER": 0,
	"FLOWER": 0,
	"MOUSE": 0,
	"RED_KNIGHT": 0
}

var enemy_spawn_list: Array[StringName]
"""
	BASIC_ENEMY,
	FLOWER_ENEMY, 
	MOUSE_ENEMY, 
	CATERPILLAR_ENEMY, 
	MAD_HATTER_ENEMY, 
	RED_KNIGHT_ENEMY
"""

func setup_level(_level_manager: LevelManager, _type: LevelType, enemy_spawn_count: int):
	level_manager = _level_manager 
	type = _type
	level_camera.initialize(player)
	enemy_spawn_list = initialize_enemy_list()
	
	if _type == LevelType.BOSS:
		var boss: Enemy = JABBERWOCK_ENEMY.instantiate()
		enemies.add_child(boss)
		boss.initialize_enemy(player, enemy_data, enemy_positions, enemies, projectiles)
		boss.position = enemy_positions.get_child(0).position
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
			new_enemy.position = enemy_positions.get_child(n).position
			new_enemy.initialize_enemy(player, enemy_data, enemy_positions, enemies, projectiles)
			new_enemy.enemy_killed.connect(enemy_kill)
			
			enemy_count += 1
			
	#print(enemy_count)
	for exit in get_level_exits():
		exit.initialize(self)
		exit.exit_chosen.connect(exit_choose)

func start_level():
	for enemy in enemies.get_children():
		if enemy is Enemy:
			enemy.activate_enemy()
		else:
			push_warning("Non-enemy found as child in Enemies node in level scene")

func enemy_kill(enemy: Enemy):
	enemies_killed += 1
	
	var enemy_position: Vector3 = enemy.position
	var money_pickup: MoneyPickup = MONEY_PICKUP.instantiate()
	add_child(money_pickup)
	money_pickup.position = enemy_position + Vector3(0.0, 1.0 * randf(), 0.0)
	
	if enemies_killed == enemy_count:
		for exit in get_level_exits():
			exit.activate()

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

	if enemy_spawn_limits["BASIC"] > 0:
		list.append(&"BASIC")
	if enemy_spawn_limits["CATERPILLAR"] > 0:
		list.append(&"CATERPILLAR")
	if enemy_spawn_limits["MAD_HATTER"] > 0:
		list.append(&"MAD_HATTER")
	if enemy_spawn_limits["FLOWER"] > 0:
		list.append(&"FLOWER")
	if enemy_spawn_limits["MOUSE"] > 0:
		list.append(&"MOUSE")
	if enemy_spawn_limits["RED_KNIGHT"] > 0:
		list.append(&"RED_KNIGHT")
	
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
	if type == &"BASIC":
		return enemy_spawn_count["BASIC"] <= enemy_spawn_limits["BASIC"]
	elif type == &"CATERPILLAR":
		return enemy_spawn_count["CATERPILLAR"] <= enemy_spawn_limits["CATERPILLAR"]
	elif type == &"MAD_HATTER":
		return enemy_spawn_count["MAD_HATTER"] <= enemy_spawn_limits["MAD_HATTER"]
	elif type == &"FLOWER":
		return enemy_spawn_count["FLOWER"] <= enemy_spawn_limits["FLOWER"]
	elif type == &"MOUSE":
		return enemy_spawn_count["MOUSE"] <= enemy_spawn_limits["MOUSE"]
	else:
		return enemy_spawn_count["RED_KNIGHT"] <= enemy_spawn_limits["RED_KNIGHT"]

func update_enemy_spawn_counts(type: StringName, change: int):
	if type == &"BASIC":
		enemy_spawn_count["BASIC"] += 1 * change
	elif type == &"CATERPILLAR":
		enemy_spawn_count["CATERPILLAR"] += 1 * change
	elif type == &"MAD_HATTER":
		enemy_spawn_count["MAD_HATTER"] += 1 * change
	elif type == &"FLOWER":
		enemy_spawn_count["FLOWER"] += 1 * change
	elif type == &"MOUSE":
		enemy_spawn_count["MOUSE"] += 1 * change
	else:
		enemy_spawn_count["RED_KNIGHT"] += 1 * change
