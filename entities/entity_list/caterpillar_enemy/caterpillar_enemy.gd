class_name CaterpillarEnemy
extends Enemy

@onready var attack: Node3D = %Attacks


func prepare_states():
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", CaterpillarEnemyIdle.new(self)),
		StateInitializer.new(&"Crawl", CaterpillarEnemyCrawl.new(self)),
		StateInitializer.new(&"Shoot", CaterpillarEnemyShoot.new(self, attack))
	]

	state_machine.assign_states(enemy_states)

func _on_hurtbox_hit_received(attack_object: AttackObject) -> void:
	hurt_effect()
	resolve_hit(attack_object)
