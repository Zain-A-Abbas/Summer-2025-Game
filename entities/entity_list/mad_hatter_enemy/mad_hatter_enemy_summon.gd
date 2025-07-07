class_name MadHatterEnemySummon
extends EnemyState

var delta_count: float = 0.0
var just_summoned: bool = false
var warning_shown: bool = false
var spawn_position: Vector3
var summon_cancel_threshold: float = 0.0


func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	just_summoned = false
	warning_shown = false
	
	enemy.action_animator.play("basic_enemy_animation_library/RESET")
	spawn_position = get_closest_spawn_position()
	summon_cancel_threshold = enemy.health_component.current_health - enemy.summon_cancel_hp_amount

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	if enemy.health_component.current_health <= summon_cancel_threshold:
		enemy.attack_indicator_animator.play("hide_indicator")
		return state_machine.change_state(&"Idle")
	
	if delta_count > enemy.summon_timestamp - 1.2 && !warning_shown:
		enemy.attack_indicator_animator.play("show_indicator")
		warning_shown = true
	
	if !just_summoned && delta_count >= enemy.summon_timestamp:
		enemy.play_sound_fx(enemy.sounds, &"summon")
		
		var new_enemy: Enemy = enemy.spawn_type_list.pick_random().instantiate()
		enemy.enemy_list.add_child(new_enemy)
		new_enemy.position = spawn_position
		new_enemy.initialize_enemy(enemy.player, enemy.enemy_data, enemy.enemy_positions, enemy.enemy_list, enemy.projectiles)
		enemy.summoned_list.append(new_enemy)
		
		just_summoned = true
		delta_count = 0.0
		
		enemy.action_animator.play("basic_enemy_animation_library/attack")
		enemy.attack_indicator_animator.play("hide_indicator")
	
	if just_summoned && delta_count >= enemy.summon_cooldown:
		return state_machine.change_state(&"Idle")

func get_closest_spawn_position() -> Vector3:
	var distances: Array[float] = []
	
	for spot in enemy.enemy_positions.get_children():
		distances.append(spot.position.distance_to(enemy.position))
	
	var index: int = distances.find(distances.min())
	return enemy.enemy_positions.get_child(index).position
