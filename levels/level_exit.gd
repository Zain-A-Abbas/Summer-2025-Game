class_name LevelExit
extends CSGBox3D

signal exit_chosen

var active: bool = false

func activate():
	active = true
	
	if material is StandardMaterial3D:
		material.albedo_color = Color.GREEN


func _on_area_3d_body_entered(body: Node3D) -> void:
	if !active:
		return
	
	if body is Player:
		exit_chosen.emit()
	else:
		push_error("Non-player triggered LevelExit collision")
