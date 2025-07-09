class_name ParalysisEffect
extends AttackEffect

@export var stun_duration: float
@export var stun_chance: float ## Chance to trigger effect

func _init():
	effect_type = AttackEffectType.PARALYSIS

func initialize_effect(args: Dictionary[String, Variant]):
	if args.has("duration"):
		stun_duration = args["duration"]
	if args.has("chance"):
		stun_chance = args["chance"]

func apply_effect(target: CharacterEntity, delta: float = 0.0, delivering_object: AttackObject = null) -> bool:
	var roll: float = randf_range(0, 100.0)
	
	if roll <= stun_chance && !target.paralyzed:
		target.paralysis_timer = 0.0
		target.paralysis_duration = stun_duration
		target.paralyzed = true
		target.state_machine.change_state(&"Idle")
	#else:
	#	print("failed to paralyze"))
	
	return true
