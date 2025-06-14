class_name AttackHitbox
extends Area3D

@onready var attack_object: AttackObject

func _ready() -> void:
	if get_parent() is AttackObject:
		attack_object = get_parent()
	else:
		push_error("AttackHitbox without AttackObject parent")
