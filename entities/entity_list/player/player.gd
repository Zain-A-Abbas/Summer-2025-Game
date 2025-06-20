class_name Player
extends CharacterEntity

signal player_damage_taken(player: Player, damage: int)

const DODGE_REQUIREMENT: float = 50
const PARRY_REQUIREMENT: float = 20

@onready var basic_attack: AttackObject = %basic_attack
@export var hurtbox: HurtboxComponent

# Required for parrying/dodging
var stamina: float = 100.0
var regenerating_stamina: bool = true
var stamina_regeneration_cooldown: SceneTreeTimer = null

func _ready() -> void:
	prepare_states()

func _physics_process(delta: float) -> void:
	if regenerating_stamina:
		stamina = minf(stamina + delta * 100.0, 100.0)

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

# regeneration_cooldown is the amount of time before stamina starts regenerating again
# is overwritten whenever another stamina action is taken
func consume_stamina(amount: int, regeneration_cooldown: float):
	regenerating_stamina = false
	stamina -= amount
	
	var new_timer: bool = !stamina_regeneration_cooldown
	if stamina_regeneration_cooldown:
		new_timer = stamina_regeneration_cooldown.time_left == 0.0
		if !new_timer:
			stamina_regeneration_cooldown.time_left = regeneration_cooldown
	
	if new_timer:
		stamina_regeneration_cooldown = get_tree().create_timer(regeneration_cooldown)
		stamina_regeneration_cooldown.timeout.connect(enable_stamina_regen)

func enable_stamina_regen():
	regenerating_stamina = true

func can_dodge():
	return stamina > 0.0

func can_parry():
	return stamina > 0.0

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	pass

func _on_hurtbox_hit_received(attack_object: AttackObject) -> void:
	print("player hit")
	resolve_hit(attack_object)
