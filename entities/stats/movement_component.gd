class_name MovementComponent
extends Node

## Contains the basic data properties for entity movement
@export var move_speed: float


func set_move_speed(new: float):
	move_speed = new
