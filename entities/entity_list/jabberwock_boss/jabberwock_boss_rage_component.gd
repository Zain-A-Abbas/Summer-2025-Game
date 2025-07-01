class_name JabberwockBossRageComponent
extends Node

@export var entity: CharacterEntity
@export var current_rage: int
@export var max_rage: int

func _ready() -> void:
	assert(entity)
	current_rage = 0
