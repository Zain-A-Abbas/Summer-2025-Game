class_name FlowerEnemyShoot
extends EnemyState

# Used to access the AnimationEffects node for visuals.
const SHOOT_TIMES: Array[float] = [0.6, 1.3]
const WARNING_TIMES: Array[float] = [0.3, 0.6]

var bomb_shot: bool= false
var warning_trackers: Array[float] = [0.0, 0.0]
var warning_shown: bool = false
var warning_hidden: bool = false

var delta_count: float = 0.0
#var animation_time: float = 0.0
var attack_object: AttackObject
var bomb: CharacterEntity
var direction: Vector3 = Vector3.ZERO

func _init(new_enemy: Enemy, object: CharacterEntity, atk_object: AttackObject) -> void:
	enemy = new_enemy
	bomb = object
	attack_object = atk_object
	
func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	bomb_shot = false
	warning_trackers.fill(0.0)
	warning_hidden = false
	warning_shown = false
	delta_count = 0.0

func st_physics_process(delta: float) -> void:
	delta_count += delta
	for n in warning_trackers.size():
		warning_trackers[n] += delta
	
	if warning_trackers[0] > WARNING_TIMES[0] && !warning_shown:
		enemy.attack_indicator_animator.play("show_indicator")
		warning_shown = true
	
	if warning_trackers[1] > WARNING_TIMES[1] && !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
		warning_hidden = true
		
	# enemy is always facing player
	direction = enemy.get_direction_to_player(enemy)
	enemy.entity_animator.rotation.y = Vector2(-direction.x, direction.z).angle() + deg_to_rad(270)
	
	if delta_count >= SHOOT_TIMES[0] && !bomb_shot:
		bomb_shot = true
		bomb.state_machine.change_state(&"Midair", {
			"dir" = direction.normalized(),
			"return" = bomb.position
			})
	
	if delta_count > SHOOT_TIMES[1]:
		state_machine.change_state(&"Idle")
		return

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	if !warning_hidden:
		enemy.attack_indicator_animator.play("hide_indicator")
