class_name AttackObject
extends Node3D

@export var entity: CharacterEntity
@export var attack_effects: Array[AttackEffect] = []
@export var hitbox: Area3D


func _ready() -> void:
	assert(entity)


func _on_attack():
	pass
