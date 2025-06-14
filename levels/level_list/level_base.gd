class_name LevelBase
extends Node3D

signal level_completed(level: LevelBase)

@onready var static_geometry: Node3D = %StaticGeometry
@onready var dynamic_geometry: Node3D = %DynamicGeometry
@onready var enemies: Node3D = %Enemies
@onready var lighting: Node3D = %Lighting
@onready var world_environment: WorldEnvironment = %WorldEnvironment
@onready var level_camera: Camera3D = %LevelCamera
@onready var enemy_positions: Node3D = %EnemyPositions

const BASIC_ENEMY = preload("res://entities/entity_list/basic_enemy/basic_enemy.tscn")

var enemy_count: int = 0
var enemies_killed: int = 0

func setup_level(enemy_spawn_count: int):
	for n in enemy_spawn_count:
		if n > enemy_positions.get_child_count():
			push_error("More enemies provided to a level than it has positions for.")
			break
		
		var new_enemy: Enemy = BASIC_ENEMY.instantiate()
		enemies.add_child(new_enemy)
		new_enemy.position = enemy_positions.get_child(n).position
		new_enemy.enemy_killed.connect(enemy_kill)
		
		enemy_count += 1
		

func start_level():
	for enemy in enemies.get_children():
		if enemy is Enemy:
			enemy.activate_enemy()
		else:
			push_warning("Non-enemy found as child in Enemies node in level scene")

func enemy_kill():
	enemies_killed += 1
