class_name HealthComponent
extends Node

## Contains data for health properties

@export var entity: CharacterEntity
@export var current_health: int
@export var max_health: int

func _ready() -> void:
	assert(entity)

func initialize_health_component(max: int) -> void:
	max_health = max
	current_health = max

func set_current_health(new: int) -> void:
	current_health = new
	if current_health > max_health:
		current_health = max_health
	elif current_health < 0:
		current_health = 0
		
func lose_health(new: int) -> void:
	set_current_health(new)
