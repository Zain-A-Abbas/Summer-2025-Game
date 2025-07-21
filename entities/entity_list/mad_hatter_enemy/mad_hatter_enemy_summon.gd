class_name MadHatterEnemySummon
extends EnemyState

const SUMMONING_WHOOSH_TIME: float = 0.4

var delta_count: float = 0.0
var just_summoned: bool = false
var warning_shown: bool = false
var spawn_position: Vector3
var summon_cancel_threshold: float = 0.0
var summon_sound_timer: float
var summon_sound_index: int

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	summon_sound_timer = 0.0
	summon_sound_index = 2
	just_summoned = false
	warning_shown = false
	
	enemy.action_animator.play("mad_hatter_animations/summon")
	spawn_position = get_closest_spawn_position()
	summon_cancel_threshold = enemy.health_component.current_health - enemy.summon_cancel_hp_amount
	
	enemy.play_sound_fx(&"magic_whoosh_1")
	enemy.summoning_particles.emitting = true

func st_physics_process(delta: float) -> void:
	delta_count += delta
	summon_sound_timer += delta
	
	if enemy.health_component.current_health <= summon_cancel_threshold:
		enemy.attack_indicator_animator.play("hide_indicator")
		return state_machine.change_state(&"Idle")
	
	if delta_count > enemy.summon_timestamp - 1.2 && !warning_shown:
		enemy.attack_indicator_animator.play("show_indicator")
		warning_shown = true
		
	# summoning attempt sfx and display particles
	if !just_summoned && summon_sound_timer >= SUMMONING_WHOOSH_TIME:
		enemy.summoning_particles.restart()
		
		enemy.play_sound_fx("magic_whoosh_%d" % summon_sound_index)
		summon_sound_index += 1
		
		summon_sound_timer = 0.0
		if summon_sound_index > 3:
			summon_sound_index = 1
	
	if !just_summoned && delta_count >= enemy.summon_timestamp:
		enemy.play_sound_fx(&"summon")
		
		var new_enemy: Enemy = enemy.spawn_type_list.pick_random().instantiate()
		enemy.enemy_list.add_child(new_enemy)
		new_enemy.position = spawn_position
		new_enemy.initialize_enemy(enemy.player, enemy.enemy_data, enemy.enemy_positions, enemy.enemy_list, enemy.projectiles)
		new_enemy.add_child(enemy.summoned_particles.duplicate())
		new_enemy.get_node("SummonedParticles").emitting = true
		
		enemy.summoned_list.append(new_enemy)
		
		just_summoned = true
		delta_count = 0.0
		
		#enemy.action_animator.play("basic_enemy_animation_library/attack")
		enemy.attack_indicator_animator.play("hide_indicator")
	
	if just_summoned && delta_count >= enemy.summon_cooldown:
		return state_machine.change_state(&"Idle")

func get_closest_spawn_position() -> Vector3:
	var distances: Array[float] = []
	
	for spot in enemy.enemy_positions.get_children():
		distances.append(spot.global_position.distance_to(enemy.global_position))
	
	var index: int = distances.find(distances.min())
	return enemy.enemy_positions.get_child(index).global_position
