class_name CharacterEntity
extends CharacterBody3D

const GRAVITY_ACCELERATION: float = 98

## A class used for characters. Holds an animator, collision, a state machine, 
## and stats

@onready var state_machine: StateMachine = %StateMachine
@onready var animation_effects: AnimationPlayer = $AnimationEffects
@onready var sounds: Node3D = %Sounds
@onready var health_component: HealthComponent = %HealthComponent
@onready var movement_component: MovementComponent = %MovementComponent


var gravity_vel: float = 0

func char_entity_die(args: Dictionary[String, Variant] = {}):
	pass
	
func play_sound_fx(sound: Node3D, name: String):
	sound.get_node(name).play()

func gravity_velocity() -> Vector3:
	if is_on_floor():
		gravity_vel = 0
	else:
		gravity_vel -= GRAVITY_ACCELERATION
	return Vector3(0, gravity_vel, 0)

func resolve_hit(attack_object: AttackObject):
	var attack_effects: Array[AttackEffect] = attack_object.attack_effects
	for effect in attack_effects:
		effect.apply_effect(self, attack_object)

func face_direction(dir: Vector3):
	rotation.y = Vector2(dir.x, -dir.z).angle() + deg_to_rad(90)
