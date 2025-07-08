class_name MouseEnemy
extends Enemy

@export var hurtbox: HurtboxComponent
@export var active_range: Array[float] = [2.5, 10.0]
@export var run_duration: float = 2.0
@export var minimum_speed: float = 100
@export var minimum_charge_time: float = 0.3
@export var charge_duration: float = 1.0
@export var change_direction_timestamp: float = 1.2
@export var dig_duration: float = 3.5
@export var dig_speeds: Dictionary[StringName, float] = {
	&"digging_down": 150.0,
	&"underground": 600.0
}
@export var underground_timestamp: float = 0.8
@export var pounce_duration: float = 0.4
@export var pounce_speed: float = 1700.0
@export var pounce_cooldown: float = 1.0

@onready var thrust: AttackObject = %basic_attack
@onready var ray_cast: RayCast3D = %ray_cast


func prepare_states():
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", MouseEnemyIdle.new(self)),
		StateInitializer.new(&"Run", MouseEnemyRun.new(self, ray_cast)),
		StateInitializer.new(&"Charge", MouseEnemyCharge.new(self)),
		StateInitializer.new(&"Dig", MouseEnemyDig.new(self, ray_cast)),
		StateInitializer.new(&"Pounce", MouseEnemyPounce.new(self, thrust))
	]
	
	state_machine.assign_states(enemy_states)

func _on_hurtbox_hit_received(attack_object: AttackObject, invin: bool) -> void:
	if !invin:
		play_sound_fx(sounds, &"damaged")
		play_sound_fx(sounds, &"damaged_squeal")
		hurt_effect()
		resolve_hit(attack_object)

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	enemy_killed.emit(self)
	queue_free()
