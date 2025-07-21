class_name MadHatterEnemy
extends Enemy

@export var spawn_type_list: Array[Resource] = []
@export var summon_cancel_hp_amount: int = 30
@export var summon_timestamp: float = 4.0
@export var summon_cooldown: float = 3.0
@export var wander_duration: float = 4.0
@export var change_direction_time: float = 0.9
@export var max_speed: float = 600

var summoned_list: Array[Enemy] = []

@onready var ray_cast: RayCast3D = %ray_cast
@onready var summoning_particles: GPUParticles3D = %SummoningParticles
@onready var summoned_particles: GPUParticles3D = %SummonedParticles

func prepare_states():
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", MadHatterEnemyIdle.new(self)),
		StateInitializer.new(&"Wander", MadHatterEnemyWander.new(self, ray_cast)),
		StateInitializer.new(&"Summon", MadHatterEnemySummon.new(self)),
		StateInitializer.new(&"Death", DeathState.new(
			self, 
			"mad_hatter_animations/death", # change later
			death_state_duration
		))
	]
	
	state_machine.assign_states(enemy_states)

func _on_hurtbox_hit_received(attack_object: AttackObject, invin: bool) -> void:
	if !invin:
		play_sound_fx(&"damaged")
		play_sound_fx(&"damaged_squeal")
		hurt_effect()
		resolve_hit(attack_object)
	
func char_entity_die(args: Dictionary[String, Variant]  = {}):
	super(args)
	RunStats.enemies_killed += 1
	
	if summoned_list.size() > 0:
		play_sound_fx(&"summon")
	
	for summoned in summoned_list:
		if summoned:
			summoned.char_entity_die({"summoned": true})
	
	state_machine.change_state(&"Death")
	
