class_name MouseEnemyThrust
extends EnemyState

const LENGTH: float = 0.5
const THRUST_SPEED: float = 1400.0
const HIDE_TIME: float = 0.5

var attack_activated: bool= false
var delta_count: float = 0.0
var animation_time: float = 0.0
var attack_object: AttackObject
var direction: Vector3 = Vector3.ZERO

func _init(new_enemy: Enemy, object: AttackObject) -> void:
	enemy = new_enemy
	attack_object = object

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	if args.has("direction"):
		direction = args["direction"]
	
	attack_activated = false
	delta_count = 0.0

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	if !attack_activated:
		attack_activated = true
		attack_object.hitbox.monitorable = true
		enemy.animation_effects.play("basic_attack")
	
	if delta_count > LENGTH:
		state_machine.change_state(&"Idle", {"from_thrust" = true})
		return
	
	enemy.velocity = direction * THRUST_SPEED * delta
	enemy.move_and_slide()

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	enemy.attack_indicator_animator.play("hide_indicator")
