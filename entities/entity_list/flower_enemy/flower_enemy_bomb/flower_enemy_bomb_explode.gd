class_name FlowerEnemyBombExplode
extends ProjectileState

const EXPLOSION_TIME: float = 0.67

var delta_count: float = 0
var attack_object: AttackObject
var bomb: FlowerEnemyBomb

func _init(new: FlowerEnemyBomb, object: AttackObject) -> void:
	bomb = new
	attack_object = object

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0
	attack_object.hitbox.show()

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	if delta_count >= EXPLOSION_TIME:
		state_machine.change_state(&"Idle")

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	bomb.entity_animator.hide()
	attack_object.hitbox.hide()
