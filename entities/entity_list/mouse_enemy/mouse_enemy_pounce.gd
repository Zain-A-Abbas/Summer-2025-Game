class_name MouseEnemyPounce
extends EnemyState

var delta_count: float = 0.0
var attack_object: AttackObject
var direction: Vector3 = Vector3.ZERO


func _init(new_enemy: Enemy, object: AttackObject) -> void:
	enemy = new_enemy
	attack_object = object

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	
	direction = face_player()
	
	attack_object.hitbox.monitorable = true
	enemy.action_animator.play("mouse/thrust")
	enemy.play_sound_fx(&"pounce_whoosh")
	enemy.play_sound_fx(&"pounce_squeal")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	if delta_count > enemy.pounce_duration:
		return state_machine.change_state(&"Idle", {"from_pounce" = true})
	
	enemy.velocity = direction * enemy.pounce_speed * delta
	enemy.move_and_slide()

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	attack_object.hitbox.monitorable = false
