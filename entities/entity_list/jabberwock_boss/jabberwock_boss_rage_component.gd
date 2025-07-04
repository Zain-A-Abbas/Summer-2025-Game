class_name JabberwockBossRageComponent
extends Node

const RAGE_DECAY: int = 5
const RAGE_DECAY_TIME: float = 0.8
const RAGE_COST_TO_COMBO: int = 100

@export var entity: CharacterEntity
@export var current_rage: int
@export var max_rage: int

var delta_count: float = 0.0


func _ready() -> void:
	assert(entity)
	current_rage = 0

func increase_rage() -> void:
	if current_rage < max_rage:
		current_rage += 10

func decay_rage(delta: float) -> void:
	delta_count += delta
	
	if delta_count > RAGE_DECAY_TIME:
		if current_rage <= RAGE_DECAY:
			current_rage = 0
		else:
			current_rage -= RAGE_DECAY
		
		delta_count = 0.0
		print("Rage: ", current_rage)
	
func consume_rage() -> void:
	current_rage -= RAGE_COST_TO_COMBO
	if current_rage < 0:
		current_rage = 0
