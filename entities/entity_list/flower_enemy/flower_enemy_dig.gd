class_name FlowerEnemyDig
extends EnemyState

const UNDERGROUND_TIMESTAMP: float = 0.8
const DIG_SOUND_TIME: float = 0.3

var delta_count: float = 0.0
var dig_sound_timer: float = 0.0
var cooldown_timer: int = 0
var dig_duration: float = 0.0

var new_dig_spot: DigSpot
var dig_spots: Node3D
var new_dig_spot_index: int

var dig_sound_index: int = 0
var is_underground: bool = false


func _init(new_enemy: Enemy, spots: Node3D) -> void:
	enemy = new_enemy
	dig_spots = spots

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	dig_sound_timer = 0.0
	dig_sound_index = 1
	is_underground = false
	
	dig_spots.get_child(enemy.prev_dig_spot_index).in_use = false
	new_dig_spot_index = enemy.get_random_dig_spot_to_player()
	new_dig_spot = dig_spots.get_child(new_dig_spot_index)
	new_dig_spot.in_use = true
	
	dig_duration = UNDERGROUND_TIMESTAMP + randf_range(1.0, 2.0)
	
	enemy.play_sound_fx(enemy.sounds, &"dig_start")
	# play initial dig animation here

func st_physics_process(delta: float) -> void:
	delta_count += delta
	dig_sound_timer += delta
	
	if delta_count >= UNDERGROUND_TIMESTAMP && !is_underground:
		enemy.hurtbox.invincibility_frames = true
		enemy.hide()
		is_underground = true
	
	if is_underground && delta_count < dig_duration:
		# play digging fx
		if dig_sound_timer > DIG_SOUND_TIME:
			enemy.play_sound_fx(enemy.sounds, "digging_%d" % dig_sound_index)
			dig_sound_index += 1
			
			dig_sound_timer = 0.0
			if dig_sound_index > 5:
				dig_sound_index = 1
	
	if delta_count >= dig_duration:
		enemy.show()
	
		enemy.position = new_dig_spot.position
		#print(enemy.name, enemy.position)
		enemy.play_sound_fx(enemy.sounds, &"dig_stop")
		return state_machine.change_state(&"Idle", {"from_dig": true})

func exit_state(previous_state: State, args: Dictionary[String, Variant]):
	enemy.hurtbox.invincibility_frames = false
	enemy.prev_dig_spot_index = new_dig_spot_index
	enemy.dig_timer = 0.0
