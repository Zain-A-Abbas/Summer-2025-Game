extends Node
class_name Game

@onready var title_layer: TitleLayer = %TitleLayer
@onready var simple_transitions: ColorRect = %SimpleTransitions
@onready var gameplay_layer: CanvasLayer = %GameplayLayer
@onready var level_manager: LevelManager = %LevelManager

func _ready() -> void:
	title_layer.run_start_selected.connect(startRun)
	title_layer.visible = true
	gameplay_layer.visible = false
	
	startGame()

func startGame():
	simple_transitions.color = Color.BLACK
	simple_transitions.modulate.a = 1.0
	simple_transitions.visible = true
	var tween: Tween = create_tween()
	tween.tween_property(simple_transitions, "modulate:a", 0.0, 1.0)
	await tween.finished
	simple_transitions.visible = false
	title_layer.titleInitialize()

func startRun():
	simple_transitions.modulate.a = 0.0
	simple_transitions.visible = true
	var tween: Tween = create_tween()
	tween.tween_property(simple_transitions, "modulate:a", 1.0, 0.5)
	await tween.finished
	title_layer.visible = false
	title_layer.set_process(false)
	gameplay_layer.visible = true
	tween = create_tween()
	tween.tween_property(simple_transitions, "modulate:a", 0.0, 0.5)
	await tween.finished
	simple_transitions.visible = false
	simple_transitions.modulate.a = 0.0
	
	level_manager.begin_run()
