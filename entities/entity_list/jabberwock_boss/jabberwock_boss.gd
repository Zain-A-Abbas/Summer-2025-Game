class_name JabberwockBoss
extends Enemy

@onready var basic_attack: Node3D = %basic_attack

func prepare_states():
	var boss_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", JabberwockBossIdle.new(self)),
		StateInitializer.new(&"Move", JabberwockBossMove.new(self)),
		StateInitializer.new(&"Shoot", JabberwockBossShoot.new(self)),
		StateInitializer.new(&"Sweep", JabberwockBossSweep.new(self)),
		StateInitializer.new(&"Swipe", JabberwockBossSwipe.new(self))
	]
	
	state_machine.assign_states(boss_states)

func _on_hurtbox_hit_received(attack_object: AttackObject) -> void:
	hurt_effect()
	resolve_hit(attack_object)
