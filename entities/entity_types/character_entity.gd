class_name CharacterEntity
extends CharacterBody3D

## A class used for characters. Holds an animator, collision, a state machine, 
## and stats

@onready var entity_animator: EntityAnimator = %EntityAnimator
@onready var state_machine: StateMachine = %StateMachine
@onready var animation_effects: AnimationPlayer = $AnimationEffects
@onready var health_data: HealthObject = %Health
@onready var move_data: MovementData = %MovementData

func char_entity_die(args: Dictionary[String, Variant]):
	pass
