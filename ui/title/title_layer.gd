extends CanvasLayer
class_name TitleLayer

signal run_start_selected

@onready var title_label: Label = %TitleLabel
@onready var title_options_container: MarginContainer = %TitleOptionsContainer
@onready var title_select: NinePatchRect = %TitleSelect
@onready var new_run_label: Label = %NewRunLabel
@onready var exit_label: Label = %ExitLabel

enum TitleState {
	NONE,
	SELECTING
}

var state: TitleState = TitleState.NONE
var currentOption: int = -1

func _ready() -> void:
	title_select.visible = false
	title_label.modulate.a = 0.0
	title_options_container.modulate.a = 0.0
	

func _input(event: InputEvent) -> void:
	if state == TitleState.NONE:
		return
	
	if event.is_action_pressed("ui_accept"):
		selectOption()
		return
	
	if event.is_action_pressed("ui_up"):
		moveHighlight(-1)
		return
	
	if event.is_action_pressed("ui_down"):
		moveHighlight(1)
		return

func selectOption():
	state = TitleState.NONE
	if currentOption == 0:
		run_start_selected.emit()
	elif currentOption == 1:
		get_tree().quit()

func titleInitialize():
	title_select.visible = false
	title_label.modulate.a = 0.0
	title_options_container.modulate.a = 0.0
	
	var titleTween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	titleTween.tween_property(title_label, "position", title_label.position, 1.2).from(title_label.position + Vector2(0, 160))
	titleTween.tween_property(title_options_container, "position", title_options_container.position, 1.2).from(title_options_container.position + Vector2(-80, 0))
	titleTween.tween_property(title_label, "modulate:a", 1.0, 1.0).from(0.0)
	titleTween.tween_property(title_options_container, "modulate:a", 1.0, 1.0).from(0.0)
	await titleTween.finished
	
	state = TitleState.SELECTING
	highlight(0)

func moveHighlight(dir: int):
	highlight(currentOption + dir)

func highlight(newOption: int):
	newOption = wrapi(newOption, 0, 2)
	currentOption = newOption
	var matchOption: Control = new_run_label
	if currentOption == 0:
		matchOption = new_run_label
	elif currentOption == 1:
		matchOption = exit_label
	title_select.position = matchOption.global_position
	title_select.size = matchOption.size
	title_select.size.y /= 2
	title_select.position.y += title_select.size.y / 2.0
	title_select.visible = true
