class_name CaterpillarEnemy
extends Enemy

@onready var ray_cast: RayCast3D = %ray_cast

func prepare_states():
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", CaterpillarEnemyIdle.new(self)),
		StateInitializer.new(&"Crawl", CaterpillarEnemyCrawl.new(self, ray_cast)),
		StateInitializer.new(&"Shoot", CaterpillarEnemyShoot.new(self, ray_cast))
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
