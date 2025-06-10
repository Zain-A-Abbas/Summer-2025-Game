class_name MovementComponent
extends Node

## Contains the basic data properties for entity movement

@export var entity: CharacterEntity
@export var move_speed: float

func _ready() -> void:
	assert(entity)

func set_move_speed(new: float):
	move_speed = new
