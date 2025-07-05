class_name FlowerEnemyDig
extends EnemyState

const DIG_DOWN_TIME: float = 0.8
const DIG_SOUND_TIME: float = 0.3
const DIG_COOLDOWN: int = 15

var delta_count: float = 0.0
var dig_sound_timer: float = 0.0
var cooldown_timer: int = 0
var dig_duration: float = 0.0

var dig_on_cooldown: bool = false
var dig_positions: Node3D
var dig_spot_index: int
var dig_sound_index: int = 0

func _init(new_enemy: Enemy, dig_spots: Node3D) -> void:
	enemy = new_enemy
	dig_positions = dig_spots

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	dig_sound_timer = 0.0
	dig_sound_index = 1
	
	if dig_on_cooldown:
		cooldown_timer += 1
		#print(cooldown_timer)
		if cooldown_timer >= DIG_COOLDOWN:
			cooldown_timer = 0
			dig_on_cooldown = false
		else:
			return
	
	# get new dig position index
	dig_spot_index = randi_range(0, dig_positions.get_child_count() - 1)
	
	dig_duration = DIG_DOWN_TIME + randf_range(1.0, 2.0)
	
	enemy.play_sound_fx(enemy.sounds, &"dig_start")

func st_physics_process(delta: float) -> void:
	if dig_on_cooldown:
		return state_machine.change_state(&"Idle")
	
	delta_count += delta
	dig_sound_timer += delta
	
	if delta_count >= DIG_DOWN_TIME && delta_count < dig_duration:
		enemy.hurtbox.invincibility_frames = true
		
		# play digging fx
		if dig_sound_timer > DIG_SOUND_TIME:
			enemy.play_sound_fx(enemy.sounds, "digging_%d" % dig_sound_index)
			dig_sound_index += 1
			
			dig_sound_timer = 0.0
			if dig_sound_index > 5:
				dig_sound_index = 1
	
	if delta_count >= dig_duration:
		enemy.position = dig_positions.get_child(dig_spot_index).position
		enemy.play_sound_fx(enemy.sounds, &"dig_stop")
		#print("resurfaced")
		return state_machine.change_state(&"Idle")

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	dig_on_cooldown = true
	enemy.hurtbox.invincibility_frames = false
