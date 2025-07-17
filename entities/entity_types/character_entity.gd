class_name CharacterEntity
extends CharacterBody3D

const GRAVITY_ACCELERATION: float = 98
const DECAY_BLEED_TIME: float = 4.0

## A class used for characters. Holds an animator, collision, a state machine, 
## and stats

@export var death_state_duration: float
@export var inflicted_attack_effect_limits: Dictionary[AttackEffect.AttackEffectType, int] = {
	AttackEffect.AttackEffectType.BURN: 1,
	AttackEffect.AttackEffectType.PARALYSIS: 1,
	AttackEffect.AttackEffectType.BLEED: 4
}

# attack effect vars
var inflicted_attack_effects: Array[AttackEffect] = []
var inflicted_attack_objects: Array[AttackObject] = []
var inflicted_attack_effect_count: Dictionary[AttackEffect.AttackEffectType, int] = {
	AttackEffect.AttackEffectType.BURN: 0,
	AttackEffect.AttackEffectType.PARALYSIS: 0,
	AttackEffect.AttackEffectType.BLEED: 0
}

# vars for paralysis effect
var paralysis_duration: float = 0.0
var paralysis_timer: float = 0.0
var paralyzed: bool = false

# vars for bleed effect
var bleed_decay_timer: float = 0.0

var gravity_vel: float = 0

@onready var state_machine: StateMachine = %StateMachine
@onready var animation_effects: AnimationPlayer = $AnimationEffects
@onready var sounds: Node3D = %Sounds
@onready var health_component: HealthComponent = %HealthComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var decal: Decal = %Decal

func _physics_process(delta: float) -> void:
	update_inflicted_attack_effects(delta)
	
	if inflicted_attack_effect_count[AttackEffect.AttackEffectType.BLEED] > 0:
		decay_bleed_counts(delta)
	#if self is Player:
	#	print(inflicted_attack_effect_count[AttackEffect.AttackEffectType.BLEED])

func char_entity_die(args: Dictionary[String, Variant] = {}):
	pass
	
func play_sound_fx(name: String):
	sounds.get_node(name).play()

func gravity_velocity() -> Vector3:
	if is_on_floor():
		gravity_vel = 0
	else:
		gravity_vel -= GRAVITY_ACCELERATION
	return Vector3(0, gravity_vel, 0)

func resolve_hit(object: AttackObject):
	var attack_effects: Array[AttackEffect] = object.attack_effects
	for effect in attack_effects:
		if check_inflicted_attack_effect_counts(effect.effect_type):
			update_inflicted_attack_effect_counts(effect.effect_type, 1)
			inflicted_attack_effects.append(effect)
			inflicted_attack_objects.append(object.duplicate())
	for hitbox in object.hitboxes:
		hitbox.monitorable = false

func face_direction(dir: Vector3):
	rotation.y = Vector2(dir.x, -dir.z).angle() + deg_to_rad(90)

func paralysis_effect(delta: float) -> bool:
	if !paralyzed:
		return false
	
	paralysis_timer += delta
	if paralysis_timer > paralysis_duration:
		paralyzed = false
		return true
		
	return true

func decay_bleed_counts(delta: float):
	bleed_decay_timer += delta
	if bleed_decay_timer >= DECAY_BLEED_TIME:
		update_inflicted_attack_effect_counts(AttackEffect.AttackEffectType.BLEED, -1)
		bleed_decay_timer = 0.0

func update_inflicted_attack_effects(delta: float):
	var n: int = 0
	
	#if self is Player:
	#	print("count: ", inflicted_attack_effect_count)
	#	print("limit: ", inflicted_attack_effect_limits)
	for effect in inflicted_attack_effects:
		if effect.apply_effect(self, delta, inflicted_attack_objects[n]):
			if effect.effect_type != AttackEffect.AttackEffectType.BLEED:
				update_inflicted_attack_effect_counts(effect.effect_type, -1)
			inflicted_attack_effects.remove_at(n)
			
			inflicted_attack_objects[n].queue_free()
			inflicted_attack_objects.remove_at(n)
		else:
			n += 1

func update_inflicted_attack_effect_counts(effect_type: AttackEffect.AttackEffectType, change: int):
	if effect_type != AttackEffect.AttackEffectType.DAMAGE:
		inflicted_attack_effect_count[effect_type] += change
		if inflicted_attack_effect_count[effect_type] < 0: # underflow check
			inflicted_attack_effect_count[effect_type] = 0

func check_inflicted_attack_effect_counts(effect_type: AttackEffect.AttackEffectType) -> bool:
	if effect_type == AttackEffect.AttackEffectType.DAMAGE: # ignore damage effect
		return true
	
	return inflicted_attack_effect_count[effect_type] < inflicted_attack_effect_limits[effect_type]
