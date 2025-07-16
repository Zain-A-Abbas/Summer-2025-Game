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
const LEVEL_REWARD = preload("res://levels/level_list/shop_level/shop_item.tscn")
const ENEMIES: Dictionary[Enemy.EnemyType, Resource] = {
	Enemy.EnemyType.CARD: preload("res://entities/entity_list/basic_enemy/basic_enemy.tscn"),
	Enemy.EnemyType.FLOWER: preload("res://entities/entity_list/flower_enemy/flower_enemy.tscn"),
	Enemy.EnemyType.CATERPILLAR: preload("res://entities/entity_list/caterpillar_enemy/caterpillar_enemy.tscn"),
	Enemy.EnemyType.MAD_HATTER: preload("res://entities/entity_list/mad_hatter_enemy/mad_hatter_enemy.tscn"),
	Enemy.EnemyType.MOUSE: preload("res://entities/entity_list/mouse_enemy/mouse_enemy.tscn"),
	Enemy.EnemyType.RED_KNIGHT: preload("res://entities/entity_list/red_knight_enemy/red_knight_enemy.tscn"),
	Enemy.EnemyType.JABBERWOCK: preload("res://entities/entity_list/jabberwock_boss/jabberwock_boss.tscn")
}
const CREATE_SHOP_LEVEL_MODULO: int = 5
const CREATE_BOSS_LEVEL_MODULO: int = 10

@export var has_enemies: bool = true
@export var enemy_minimum: int = 2
@export var enemy_limit: int = 3
@export var enemy_spawn_limits: Dictionary[Enemy.EnemyType, int] = {
	Enemy.EnemyType.CARD: 0,
	Enemy.EnemyType.CATERPILLAR: 0,
	Enemy.EnemyType.FLOWER: 0,
	Enemy.EnemyType.MAD_HATTER: 0,
	Enemy.EnemyType.MOUSE: 0,
	Enemy.EnemyType.RED_KNIGHT: 0
}

var enemy_count: int = 0
var enemies_killed: int = 0
var level_manager: LevelManager
var type: LevelType
var enemy_spawn_count: Dictionary[Enemy.EnemyType, int] = {
	Enemy.EnemyType.CARD: 0,
	Enemy.EnemyType.CATERPILLAR: 0,
	Enemy.EnemyType.FLOWER: 0,
	Enemy.EnemyType.MAD_HATTER: 0,
	Enemy.EnemyType.MOUSE: 0,
	Enemy.EnemyType.RED_KNIGHT: 0
}
var enemy_spawn_list: Array[Enemy.EnemyType]
var shop_exit_made: bool = false
var reward: ShopItem

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
@onready var reward_position: Marker3D = %RewardPosition

func setup_level(_level_manager: LevelManager, _type: LevelType, enemy_spawn_count: int):
	level_manager = _level_manager 
	type = _type
	level_camera.initialize(player)
	enemy_spawn_list = initialize_enemy_list()
	shop_exit_made = false
	
	if _type == LevelType.BOSS:
		var boss: Enemy = ENEMIES[Enemy.EnemyType.JABBERWOCK].instantiate()
		enemies.add_child(boss)
		boss.position = enemy_positions.get_child(0).global_position
		boss.type = Enemy.EnemyType.JABBERWOCK
		if level_manager.scale_enemies:
			level_manager.enemy_scaler.scale_enemy(boss, 
				{
					"hp_multiplier": level_manager.enemy_hp_multiplier,
					"dmg_multiplier": level_manager.enemy_dmg_multiplier
				}
			)
		boss.initialize_enemy(player, enemy_data, enemy_positions, enemies, projectiles)
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
			var new_enemy_type: Enemy.EnemyType = enemy_spawn_list[new_enemy_index]
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
			new_enemy.type = new_enemy_type
			if level_manager.scale_enemies:
				level_manager.enemy_scaler.scale_enemy(new_enemy, 
					{
						"hp_multiplier": level_manager.enemy_hp_multiplier,
						"dmg_multiplier": level_manager.enemy_dmg_multiplier
					}
				)
			new_enemy.initialize_enemy(player, enemy_data, enemy_positions, enemies, projectiles)
			new_enemy.enemy_killed.connect(enemy_kill)
			
			enemy_count += 1
	
	# initialize reward
	if _type != LevelType.SHOP && _type != LevelType.HEALING:
		reward = LEVEL_REWARD.instantiate().duplicate()
		dynamic_geometry.add_child(reward)
	
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
		
		# spawn upgrade
		if type != LevelType.SHOP && type != LevelType.HEALING:
			spawn_level_reward(reward)

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

func initialize_enemy_list() -> Array[Enemy.EnemyType]:
	var list: Array[Enemy.EnemyType] = []
	
	for type in enemy_spawn_limits.keys():
		if enemy_spawn_limits[type] > 0:
			list.append(type)
	
	return list
	
func spawn_enemy(type: Enemy.EnemyType) -> Enemy:
	return ENEMIES[type].instantiate()

func can_enemy_spawn_type(type: Enemy.EnemyType) -> bool:
	return enemy_spawn_count[type] <= enemy_spawn_limits[type]

func update_enemy_spawn_counts(type: Enemy.EnemyType, change: int):
	enemy_spawn_count[type] += change

func spawn_level_reward(reward: ShopItem):
	reward.initialize(level_manager)
	reward.position = reward_position.position
