class_name FlowerEnemy
extends Enemy

@export var bomb: Resource
@export var attack_range: Array[float] = [4.0, 16.0]
@export var shoot_cooldown: float = 1.1
@export var warning_duration: float = 0.7
@export var dig_cooldown: float = 5.5

var dig_spots: Node3D
var prev_dig_spot_index: int = -1
var dig_timer: float = 0.0

func prepare_states():
	dig_spots = enemy_data.get_node("DigSpots")
	
	var i: int = 0
	for spot in dig_spots.get_children():
		if !spot.in_use:
			position = spot.position
			spot.in_use = true
			prev_dig_spot_index = i
			break
		i += 1
	
	var enemy_states: Array[StateInitializer] = [
		StateInitializer.new(&"Idle", FlowerEnemyIdle.new(self)),
		StateInitializer.new(&"Dig", FlowerEnemyDig.new(self, dig_spots)),
		StateInitializer.new(&"Shoot", FlowerEnemyShoot.new(self)),
		StateInitializer.new(&"Death", DeathState.new(
			self, 
			"basic_enemy_animation_library/attack", # change later
			death_state_duration
			))
	]
	
	state_machine.assign_states(enemy_states)

func _on_hurtbox_hit_received(attack_object: AttackObject, invin: bool) -> void:
	if !invin:
		play_sound_fx(&"damaged")
		hurt_effect()
		resolve_hit(attack_object)

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	enemy_killed.emit(self)
	dig_spots.get_child(prev_dig_spot_index).in_use = false
	hurtbox.set_collision_mask_value(2, 0)
	state_machine.change_state(&"Death")

func get_random_dig_spot_to_player() -> int:
	var valid_distances: Array[float] = []
	var all_distances: Array[float] = []
	var distance: float = 0.0
	var player_position: Vector3 = player.position
	
	for spot in dig_spots.get_children():
		distance = spot.position.distance_to(player_position)
		if !spot.in_use:
			valid_distances.append(distance)
		all_distances.append(distance)
	
	return all_distances.find(valid_distances.pick_random())
