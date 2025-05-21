class_name CharacterEntity
extends CharacterBody3D

## A class used for characters. Holds an animator, collision, and a state machine.

@onready var entity_animator: EntityAnimator = %EntityAnimator
@onready var state_machine: StateMachine = %StateMachine
