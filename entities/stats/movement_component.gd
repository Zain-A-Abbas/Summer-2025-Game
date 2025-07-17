class_name MovementComponent
extends Node

## Contains the basic data properties for entity movement
@export var move_speed: float

var original_move_speed: float = 0.0
var slowed: bool

func _init() -> void:
	original_move_speed = move_speed

func set_move_speed(new: float):
	move_speed = new
