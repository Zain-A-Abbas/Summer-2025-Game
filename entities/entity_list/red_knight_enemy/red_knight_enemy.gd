class_name RedKnightEnemy
extends Enemy

@onready var thrust: AttackObject = %basic_attack

@export var hurtbox: HurtboxComponent

func prepare_states():	
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", RedKnightEnemyIdle.new(self)),
		StateInitializer.new(&"Block", RedKnightEnemyBlock.new(self, hurtbox)),
		StateInitializer.new(&"Swing", RedKnightEnemySwing.new(self, thrust))
	]
	
	state_machine.assign_states(enemy_states)

func _on_hurtbox_hit_received(attack_object: AttackObject) -> void:
	hurt_effect()
	resolve_hit(attack_object)
