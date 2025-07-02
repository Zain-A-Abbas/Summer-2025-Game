class_name LevelBase
extends Node3D

signal level_completed(level: LevelBase)

const BASIC_ENEMY = preload("res://entities/entity_list/basic_enemy/basic_enemy.tscn")
const FLOWER_ENEMY = preload("res://entities/entity_list/flower_enemy/flower_enemy.tscn")
const MOUSE_ENEMY = preload("res://entities/entity_list/mouse_enemy/mouse_enemy.tscn")
const MAD_HATTER_ENEMY = preload("res://entities/entity_list/mad_hatter_enemy/mad_hatter_enemy.tscn")
const RED_KNIGHT_ENEMY = preload("res://entities/entity_list/red_knight_enemy/red_knight_enemy.tscn")
const CATERPILLAR_ENEMY = preload("res://entities/entity_list/caterpillar_enemy/caterpillar_enemy.tscn")
const JABBERWOCK_BOSS = preload("res://entities/entity_list/jabberwock_boss/jabberwock_boss.tscn")
const ENEMY_TYPE_LIST: Array[Resource] = [
	BASIC_ENEMY,
	FLOWER_ENEMY,
	MOUSE_ENEMY,
	MAD_HATTER_ENEMY,
	RED_KNIGHT_ENEMY,
	CATERPILLAR_ENEMY
	]

@onready var static_geometry: Node3D = %StaticGeometry
@onready var dynamic_geometry: Node3D = %DynamicGeometry
@onready var enemies: Node3D = %Enemies
@onready var lighting: Node3D = %Lighting
@onready var world_environment: WorldEnvironment = %WorldEnvironment
@onready var level_camera: Camera3D = %LevelCamera
@onready var enemy_positions: Node3D = %EnemyPositions
@onready var enemy_data: Node3D = %EnemyData
@onready var projectiles: Node3D = %Projectiles
@onready var player: Player = %Player

@export var enemy_limit: int = 3

var enemy_count: int = 0
var enemies_killed: int = 0

func setup_level(enemy_spawn_count: int, is_boss_level: bool):
	level_camera.initialize(player)
	
	if is_boss_level:
		var boss: Enemy = JABBERWOCK_BOSS.instantiate()
		enemies.add_child(boss)
		boss.initialize_enemy(player, enemy_data, enemy_positions, enemies, projectiles)
		boss.position =enemy_positions.get_child(0).position
		
		enemy_count += 1
	else:
		for n in enemy_spawn_count:
			if n > enemy_positions.get_child_count():
				push_error("More enemies provided to a level than it has positions for.")
				break
			
			var new_enemy: Enemy = ENEMY_TYPE_LIST.pick_random().instantiate()
			enemies.add_child(new_enemy)
			new_enemy.initialize_enemy(player, enemy_data, enemy_positions, enemies, projectiles)
			new_enemy.position = enemy_positions.get_child(n).position
			new_enemy.enemy_killed.connect(enemy_kill)
			
			enemy_count += 1
	
	for exit in get_level_exits():
		exit.exit_chosen.connect(exit_choose)

func start_level():
	for enemy in enemies.get_children():
		if enemy is Enemy:
			enemy.activate_enemy()
		else:
			push_warning("Non-enemy found as child in Enemies node in level scene")

func enemy_kill():
	enemies_killed += 1
	
	if enemies_killed == enemy_count:
		for exit in get_level_exits():
			exit.activate()

func exit_choose():
	level_completed.emit(self)

func get_level_exits() -> Array[LevelExit]:
	var exits: Array[LevelExit] = []
	
	for exit in get_tree().get_nodes_in_group("level_exits"):
		if exit is LevelExit:
			exits.append(exit)
		else:
			push_error("Non-levelexit found in level_exits group")
	
	return exits
