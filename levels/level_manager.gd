class_name LevelManager
extends Node

const LEVEL_AMOUNT: int = 5

@onready var level_holder: Node3D = %LevelHolder
@onready var fade: ColorRect = %Fade

@export var random_levels: Array[PackedScene] = []

var current_level: int = 0

func _ready() -> void:
	begin_run()

func begin_run():
	current_level = 1
	await fade_transition(true)
	create_level()

func create_level():
	var enemy_count: int = randi_range(1, 3)
	var new_level: LevelBase = random_levels.pick_random().instantiate()
	level_holder.add_child(new_level)
	new_level.setup_level(enemy_count)
	new_level.level_completed.connect(level_complete)
	
	await fade_transition(false)
	new_level.start_level()

func level_complete(level: LevelBase):
	await fade_transition(true)
	level.queue_free()
	current_level += 1
	
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
