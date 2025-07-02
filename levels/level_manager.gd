class_name LevelManager
extends Node

const LEVEL_AMOUNT: int = 8

@onready var level_holder: Node3D = %LevelHolder
@onready var fade: ColorRect = %Fade
@onready var player_ui: PlayerUI = %PlayerUI

@export var random_levels: Array[PackedScene] = []

var current_level: int = 0
var is_boss_level: bool = false

func _ready() -> void:
	pass

func begin_run():
	current_level = 1
	player_ui.visible = true
	await fade_transition(true)
	create_level()

func create_level():
	#var new_level: LevelBase = random_levels.pick_random().instantiate()
	var new_level: LevelBase = random_levels[2].instantiate()
	level_holder.add_child(new_level)
	var enemy_count: int = randi_range(1, new_level.enemy_limit)
	if new_level.name == &"BossLevel":
		is_boss_level = true
	
	new_level.setup_level(enemy_count, is_boss_level)
	new_level.level_completed.connect(level_complete)
	player_ui.refresh_player(new_level)
	
	await fade_transition(false)
	new_level.start_level()

func level_complete(level: LevelBase):
	await fade_transition(true)
	level.queue_free()
	current_level += 1
	
	await get_tree().process_frame
	
	if current_level == LEVEL_AMOUNT:
		return
	
	create_level()

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
