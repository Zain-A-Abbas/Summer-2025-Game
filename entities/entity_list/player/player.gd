class_name Player
extends CharacterEntity

@onready var basic_attack: AttackObject = %basic_attack

@export var hurtbox: HurtboxComponent

func _ready() -> void:
	prepare_states()

func prepare_states():
	# The & before string declarations marks it as a StringName, which is a
	# separate class that is much faster for string comparisons.
	var player_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", PlayerIdle.new(self)),
		StateInitializer.new(&"Walk", PlayerWalk.new(self)),
		StateInitializer.new(&"Dodge", PlayerDodge.new(self)),
		StateInitializer.new(&"Attack", PlayerBasicAttack.new(self, basic_attack))
	]
	
	state_machine.assign_states(player_states)
	
func char_entity_die(args: Dictionary[String, Variant]  = {}):
	pass

func _on_hurtbox_hit_received(attack_object: AttackObject) -> void:
	print("player hit")
	resolve_hit(attack_object)
