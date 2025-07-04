class_name CharacterEntity
extends CharacterBody3D



## A class used for characters. Holds an animator, collision, a state machine, 
## and stats

@onready var state_machine: StateMachine = %StateMachine
@onready var animation_effects: AnimationPlayer = $AnimationEffects
@onready var sounds: Node3D = %Sounds

@export var health_component: HealthComponent
@export var movement_component: MovementComponent

func char_entity_die(args: Dictionary[String, Variant] = {}):
	pass
	
func play_sound_fx(sound: Node3D, name: String):
	sound.get_node(name).play()

func resolve_hit(attack_object: AttackObject):
	var attack_effects: Array[AttackEffect] = attack_object.attack_effects
	for effect in attack_effects:
		effect.apply_effect(self, attack_object)
