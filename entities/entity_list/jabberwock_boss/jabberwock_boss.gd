class_name JabberwockBoss
extends Enemy

@onready var sweep: AttackObject = %Sweep
@onready var swipe: AttackObject = %Swipe
@onready var breath: AttackObject = %LightningBreath
@onready var rage_component: JabberwockBossRageComponent = %RageComponent

func prepare_states():
	var boss_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", JabberwockBossIdle.new(self, rage_component)),
		StateInitializer.new(&"Move", JabberwockBossMove.new(self, rage_component)),
		StateInitializer.new(&"Shoot", JabberwockBossShoot.new(self, rage_component, breath)),
		StateInitializer.new(&"Sweep", JabberwockBossSweep.new(self, rage_component, sweep)),
		StateInitializer.new(&"Swipe", JabberwockBossSwipe.new(self, rage_component, swipe))
	]
	
	state_machine.assign_states(boss_states)

func _on_hurtbox_hit_received(attack_object: AttackObject) -> void:
	rage_component.increase_rage()
	hurt_effect()
	resolve_hit(attack_object)

func can_combo() -> bool:
	if rage_component.current_rage < rage_component.RAGE_COST_TO_COMBO:
		return false
	
	var chance: int = randi_range(1, 10)
	var rage_chance_increase: int = roundf((rage_component.current_rage - rage_component.RAGE_COST_TO_COMBO) / 100.0)
	var threshold: int = 7 - rage_chance_increase
	
	return chance > threshold
