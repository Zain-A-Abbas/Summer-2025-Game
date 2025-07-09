class_name AttackObject
extends Node3D

@export var entity: CharacterEntity
@export var attack_effects: Array[AttackEffect] = []
@export var hitbox: Area3D


func _ready() -> void:
	assert(entity)

func add_attack_effect(effect_name: StringName, args: Dictionary[String, Variant]):
	var duration: float = 0.0
	if effect_name == &"Burn":
		if args.has("duration"):
			duration = args["duration"]
		
		var burn: BurnEffect = BurnEffect.new(duration)
		attack_effects.append(burn)
	elif effect_name == &"Paralysis":
		if args.has("duration"):
			duration = args["duration"]
		
		var para: ParalysisEffect = ParalysisEffect.new(duration, args["chance"])
		attack_effects.append(para)
	else:
		print(effect_name, ": invalid effect name")
