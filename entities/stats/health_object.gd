class_name HealthObject
extends Node3D

## Contains data for health properties

@export var entity: CharacterEntity
@export var current_health: int
@export var max_health: int

func _ready() -> void:
	assert(entity)

func initialize_health_data(max: int) -> void:
	max_health = max
	current_health = max

func set_current_health(new: int) -> void:
	current_health = new
	if current_health > max_health:
		current_health = max_health
	elif current_health < 0:
		current_health = 0
