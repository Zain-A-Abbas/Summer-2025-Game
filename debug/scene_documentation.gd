class_name SceneDocumentation
extends MarginContainer


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	visible = false
	set_process(false)
