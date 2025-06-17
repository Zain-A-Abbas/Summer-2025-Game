class_name MouseEnemyCharge
extends EnemyState

const CHARGE_TIME: float = 1.0

var delta_count: float = 0
var direction: Vector3 = Vector3.ZERO

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0

func st_physics_process(delta: float) -> void:
	delta_count += delta

	direction = enemy.position.direction_to(enemy.player.position).normalized()

	if delta_count >= CHARGE_TIME:
		state_machine.change_state(&"Idle", {"direction" = direction})
		return
