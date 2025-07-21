class_name LevelBase
extends Node3D

signal level_completed(level: LevelBase, next_level: LevelType)

enum LevelType {
	NONE,
	NORMAL,
	ELITE,
	SHOP,
	HEALING,
	BOSS
}

const MONEY_PICKUP = preload("res://levels/pickups/money_pickup.tscn")
const LEVEL_REWARD: Resource = preload("res://levels/level_list/shop_level/shop_item.tscn")
const ENEMIES: Dictionary[Enemy.EnemyType, String] = {
	Enemy.EnemyType.CARD: "res://entities/entity_list/basic_enemy/basic_enemy.tscn",
	Enemy.EnemyType.FLOWER: "res://entities/entity_list/flower_enemy/flower_enemy.tscn",
	Enemy.EnemyType.CATERPILLAR: "res://entities/entity_list/caterpillar_enemy/caterpillar_enemy.tscn",
	Enemy.EnemyType.MAD_HATTER: "res://entities/entity_list/mad_hatter_enemy/mad_hatter_enemy.tscn",
	Enemy.EnemyType.MOUSE: "res://entities/entity_list/mouse_enemy/mouse_enemy.tscn",
	Enemy.EnemyType.RED_KNIGHT: "res://entities/entity_list/red_knight_enemy/red_knight_enemy.tscn",
	Enemy.EnemyType.JABBERWOCK: "res://entities/entity_list/jabberwock_boss/jabberwock_boss.tscn"
}
const CREATE_SHOP_LEVEL_MODULO: int = 4
const CREATE_BOSS_LEVEL_MODULO: int = 7
const ELITE_DMG_MULTIPLIER: float = 1.25
const ELITE_HP_MULTIPLIER: float = 1.30

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
@onready var reward_positions: Node3D = %RewardPositions

func setup_level(_level_manager: LevelManager, _type: LevelType, enemy_spawn_count: int):
	level_manager = _level_manager 
	type = _type
	level_camera.initialize(player)
	player.player_died.connect(gameover)
	enemy_spawn_list = initialize_enemy_list()
	
	if _type == LevelType.BOSS:
		var boss: Enemy = spawn_enemy(Enemy.EnemyType.JABBERWOCK)
		enemies.add_child(boss)
		boss.position = enemy_positions.get_child(0).global_position
		boss.type = Enemy.EnemyType.JABBERWOCK

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
			
			enemy_count += 1

	# initialize enemies
	for enemy in enemies.get_children():
		if _type == LevelBase.LevelType.ELITE:
			level_manager.enemy_scaler.scale_enemy(enemy, 
				{
					"hp_multiplier": ELITE_HP_MULTIPLIER,
					"dmg_multiplier": ELITE_DMG_MULTIPLIER,
				}
			)
		
		if level_manager.run_scale_enemies:
			level_manager.enemy_scaler.scale_enemy(enemy, 
				{
					"hp_multiplier": level_manager.enemy_hp_multiplier,
					"dmg_multiplier": level_manager.enemy_dmg_multiplier,
					"run": true
				}
			)

		enemy.initialize_enemy(player, enemy_data, enemy_positions, enemies, projectiles)
		enemy.enemy_killed.connect(enemy_kill)

	# initialize reward(s)
	var amount: int = 0
	match _type:
		LevelType.NORMAL:
			amount = 1
		LevelType.ELITE:
			amount = 2
		LevelType.BOSS:
			amount = 3
	
	if amount:
		initialize_rewards(amount)
	
	level_manager.shop_level_made = false
	level_manager.healing_level_made = false
	for exit in get_level_exits():
		exit.initialize(self)
		exit.exit_chosen.connect(exit_choose)

func start_level(_type: LevelType):
	for enemy in enemies.get_children():
		if enemy is Enemy:
			enemy.activate_enemy()
		else:
			push_warning("Non-enemy found as child in Enemies node in level scene")
	
	if _type == LevelType.NORMAL || _type == LevelType.ELITE:
		Bgm.change_volume(1.0)
		Bgm.play_bgm(Bgm.BGM_TYPE.BATTLE)
	elif _type == LevelType.SHOP || _type == LevelType.HEALING:
		Bgm.change_volume(0.35)
	elif _type == LevelType.BOSS:
		Bgm.change_volume(1.0)
		Bgm.play_bgm(Bgm.BGM_TYPE.BOSS)
	
func gameover(player: Player):
	for enemy in enemies.get_children():
		enemy.queue_free()

	for light in lighting.get_children():
		if light is Node3D:
			light.visible = false
	
	for sound in sounds.get_children():
		if sound is AudioStreamPlayer3D:
			sound.playing = false

	for proj in projectiles.get_children():
		proj.queue_free()
		
	player.play_sound_fx(&"death")
	
	static_geometry.visible = false
	dynamic_geometry.visible = false
	
	var death_environment: Environment = Environment.new()
	death_environment.background_mode = Environment.BG_COLOR
	death_environment.background_color = Color.BLACK
	death_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	death_environment.ambient_light_color = Color.WHITE
	world_environment.environment = death_environment

func enemy_kill(enemy: Enemy):
	enemies_killed += 1
	
	var enemy_position: Vector3 = enemy.global_position
	var money_pickup: MoneyPickup = MONEY_PICKUP.instantiate()
	add_child(money_pickup)
	money_pickup.position = enemy_position + Vector3(0.0, 1.0 * randf(), 0.0)
	
	if enemies_killed == enemy_count:
		RunStats.levels_cleared += 1
		var index: int = 1
		
		# open doors
		for exit in get_level_exits():
			exit.activate()
			sounds.get_node("door_open_%d" % index).play()
			index += 1
		
		# spawn upgrade(s)
		if type != LevelType.SHOP && type != LevelType.HEALING:
			spawn_level_rewards()
		
		# play level complete sound
		sounds.get_node("level_complete").play()

func exit_choose(exit_type: LevelType, normal_level_type: LevelManager.NormalLevelType):
	level_completed.emit(self, exit_type, normal_level_type)

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
	return load(ENEMIES[type]).instantiate()

func can_enemy_spawn_type(type: Enemy.EnemyType) -> bool:
	return enemy_spawn_count[type] <= enemy_spawn_limits[type]

func update_enemy_spawn_counts(type: Enemy.EnemyType, change: int):
	enemy_spawn_count[type] += change

func initialize_rewards(amount: int):
	for n in amount:
		var reward: ShopItem = LEVEL_REWARD.duplicate(true).instantiate()
		dynamic_geometry.add_child(reward)
		reward.position = reward_positions.get_child(n).global_position

func spawn_level_rewards():
	for reward in dynamic_geometry.get_children():
		if reward is ShopItem:
			reward.initialize(level_manager)
