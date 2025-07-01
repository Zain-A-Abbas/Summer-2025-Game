class_name CaterpillarEnemyCrawl
extends EnemyState

const CRAWL_TIME: float = 2.0
const DIRECTION_CHANGE_TIME: float = 0.4

var direction: Vector3
var delta_count: float = 0.0
var direction_timer: float = 0.0

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	direction_timer = 0.0
	enemy.action_animator.play("basic_enemy_animation_library/walk")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	direction_timer += delta
	
	if delta_count >= CRAWL_TIME:
		state_machine.change_state(&"Shoot", {"direction" = face_player()})
		return
	
	if direction_timer > DIRECTION_CHANGE_TIME:
		direction = face_player().rotated(Vector3(0, 1, 0), deg_to_rad(90))
		enemy.rotation.y = get_angle_to_face_player(direction)
		direction_timer = 0.0
	
	enemy.velocity = direction * enemy.movement_component.move_speed * delta
	enemy.move_and_slide()
