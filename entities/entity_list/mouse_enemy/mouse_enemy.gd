class_name MouseEnemy
extends Enemy

@export var hurtbox: HurtboxComponent

@onready var thrust: AttackObject = %basic_attack

var jump_positions: Node3D

func prepare_states():
	jump_positions = enemy_data.get_node("JumpPositions")
	
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", MouseEnemyIdle.new(self)),
		StateInitializer.new(&"Run", MouseEnemyRun.new(self)),
		StateInitializer.new(&"Charge", MouseEnemyCharge.new(self)),
		StateInitializer.new(&"Jump", MouseEnemyJump.new(self, jump_positions)),
		StateInitializer.new(&"Thrust", MouseEnemyThrust.new(self, thrust))
	]
	
	state_machine.assign_states(enemy_states)

func _on_hurtbox_hit_received(attack_object: AttackObject, invin: bool) -> void:
	if !invin:
		play_sound_fx(sounds, &"damaged")
		hurt_effect()
		resolve_hit(attack_object)

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	enemy_killed.emit(self)
	queue_free()
