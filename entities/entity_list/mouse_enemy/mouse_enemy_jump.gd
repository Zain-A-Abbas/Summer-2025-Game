class_name MouseEnemyJump
extends EnemyState

const JUMP_TIME: float = 0.7
const INVULN_TIME: float = 0.3

var delta_count: float = 0.0
var cooldown_timer: int = 0
var direction: Vector3 = Vector3.ZERO
var jump_positions: Node3D
var jump_spot_index: int

func _init(new_enemy: Enemy, jump_spots: Node3D) -> void:
	enemy = new_enemy
	jump_positions = jump_spots

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	jump_spot_index = randi_range(0, jump_positions.get_child_count() - 1)
	
	enemy.play_sound_fx(enemy.sounds, &"jump")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	enemy.hurtbox.invincibility_frames = delta_count > INVULN_TIME
	
	if delta_count >= JUMP_TIME:
		enemy.play_sound_fx(enemy.sounds, &"land")
		enemy.position = jump_positions.get_child(jump_spot_index).position
		return state_machine.change_state(&"Idle")

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	pass
