extends Node
class_name Game

@onready var title_layer: TitleLayer = %TitleLayer
@onready var simple_transitions: ColorRect = %SimpleTransitions

func _ready() -> void:
	title_layer.run_start_selected.connect(startRun)
	title_layer.visible = true
	
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
	print("hooray")
