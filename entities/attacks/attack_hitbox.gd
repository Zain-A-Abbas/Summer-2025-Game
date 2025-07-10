@tool
class_name AttackHitbox
extends Area3D

@onready var attack_object: AttackObject
@export var follow_marker: Marker3D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if get_parent() is AttackObject:
		attack_object = get_parent()
	else:
		push_error("AttackHitbox without AttackObject parent")

func _physics_process(delta: float) -> void:
	if follow_marker:
		global_position = follow_marker.global_position
