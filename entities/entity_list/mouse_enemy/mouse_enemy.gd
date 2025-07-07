class_name MouseEnemy
extends Enemy

const DEAGGRO_DISTANCE: float = 6.5

@onready var thrust: AttackObject = %basic_attack
@onready var ray_cast: RayCast3D = %ray_cast

@export var hurtbox: HurtboxComponent


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
		hurt_effect()
		resolve_hit(attack_object)

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	enemy_killed.emit(self)
	queue_free()
