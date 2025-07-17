extends CanvasLayer
class_name TitleLayer

signal run_start_selected

@onready var title_label: Label = %TitleLabel
@onready var title_options_container: MarginContainer = %TitleOptionsContainer
@onready var title_select: NinePatchRect = %TitleSelect
@onready var new_game_button: Button = %NewGameButton
@onready var exit_game_button: Button = %ExitGameButton
@onready var credits_button: Button = %CreditsButton
@onready var exit_credits_button: Button = %ExitCredits
@onready var credits_panel: PanelContainer = %CreditsPanel

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
	Bgm.play_bgm(Bgm.BGM_TYPE.TITLE, 1.0)
	credits_panel.visible = false
	new_game_button.pressed.connect(new_game)
	exit_game_button.pressed.connect(exit_game)
	credits_button.pressed.connect(credits)
	exit_credits_button.pressed.connect(exit_credits)

func _input(event: InputEvent) -> void:
	if state == TitleState.NONE:
		return

func new_game():
	run_start_selected.emit()

func exit_game():
	get_tree().quit()

func credits():
	credits_panel.visible = true
	exit_credits_button.grab_focus()

func exit_credits():
	credits_panel.visible = false
	credits_button.grab_focus()

func title_initialize():
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
	new_game_button.grab_focus()
