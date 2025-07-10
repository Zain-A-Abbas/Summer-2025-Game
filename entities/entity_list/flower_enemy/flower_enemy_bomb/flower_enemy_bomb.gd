class_name FlowerEnemyBomb
extends CharacterEntity

@export var time_to_live: float = 1.1
@export var explosion_duration: float = 0.85

@onready var atk_obj: AttackObject = %Explosion
@onready var model: CSGSphere3D = %placeholder_model # NOTE: temporary visual effect
@onready var explosion_particles: GPUParticles3D = %ExplosionParticles

const BOMB_HORIZONTAL_VELOCITY: float = 32.0
const BOMB_STARTING_VERTICAL_VELOCITY: float = 4.0
const BOMB_GRAVITY: float = 98

var bomb_velocity: Vector3 = Vector3.ZERO
var start_position: Vector3
var goal_position: Vector3


func initialize_bomb(_start_position: Vector3, _goal_position: Vector3) -> void:
	start_position = _start_position
	goal_position = _goal_position
	bomb_velocity = Vector3(0, BOMB_STARTING_VERTICAL_VELOCITY, 0)
	global_position = start_position
	prepare_states()

func prepare_states():
	var bomb_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", FlowerEnemyBombIdle.new(self)),
		StateInitializer.new(&"Wait", FlowerEnemyBombWait.new(self, model)),
		StateInitializer.new(&"Explode", FlowerEnemyBombExplode.new(self, model, atk_obj))
	]
	
	state_machine.assign_states(bomb_states)
	model.hide()
	atk_obj.hide()

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	queue_free()
