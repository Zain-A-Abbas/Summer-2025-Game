class_name AttackObject
extends Node3D

@export var entity: CharacterEntity
@export var attack_effects: Array[AttackEffect] = []
@export var hitbox: Area3D


func _ready() -> void:
	assert(entity)

func add_attack_effect(effect_type: StringName, args: Dictionary[String, Variant]):
	var duration: float = 0.0
	if effect_type == &"BURN":
		if args.has("duration"):
			duration = args["duration"]
		
		var burn: BurnEffect = BurnEffect.new()
		burn.initialize_effect({"duration": duration})
		attack_effects.append(burn)
	elif effect_type == &"PARALYSIS":
		if args.has("duration"):
			duration = args["duration"]
		
		var para: ParalysisEffect = ParalysisEffect.new()
		para.initialize_effect({"duration": duration, "chance": args["chance"]})
		attack_effects.append(para)
	else:
		print(effect_type, ": invalid effect type")
