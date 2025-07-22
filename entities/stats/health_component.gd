class_name HealthComponent
extends Node

## Contains data for health properties
@export var entity: CharacterEntity
@export var current_health: int
@export var max_health: int
@export var base_max_health: int


func initialize_health_component(max_amount: int) -> void:
	max_health = max_amount
	current_health = max_amount

func set_current_health(new: int) -> void:
	current_health = new
	if current_health > max_health:
		current_health = max_health
	elif current_health < 0:
		current_health = 0

func lose_health(new: int) -> void:
	set_current_health(new)
	if entity is Player:
		entity.player_damage_taken.emit(entity, new)
	if entity is Enemy:
		entity.enemy_damage_taken.emit(entity, new)
