class_name AttackObject
extends Node3D

@export var entity: CharacterEntity
@export var attack_effects: Array[AttackEffect] = []
@export var hitboxes: Array[Area3D]


func _ready() -> void:
	assert(entity)

func add_attack_effect(effect_type: AttackEffect.AttackEffectType, args: Dictionary[String, Variant]):
	var duration: float = 0.0
	match effect_type:
		AttackEffect.AttackEffectType.BURN:
			if args.has("duration"):
				duration = args["duration"]
			
			var burn: BurnEffect = BurnEffect.new()
			burn.initialize_effect({"duration": duration})
			attack_effects.append(burn)
		AttackEffect.AttackEffectType.PARALYSIS:
			if args.has("duration"):
				duration = args["duration"]
			
			var para: ParalysisEffect = ParalysisEffect.new()
			para.initialize_effect({"duration": duration, "chance": args["chance"]})
			attack_effects.append(para)
		AttackEffect.AttackEffectType.BLEED:
			var bleed: BleedEffect = BleedEffect.new()
			attack_effects.append(bleed)
		_:
			print(effect_type, ": invalid effect type")
