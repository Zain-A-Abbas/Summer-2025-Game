class_name MadHatterEnemySummon
extends EnemyState

# can only spawn these
const BASIC_ENEMY = preload("res://entities/entity_list/basic_enemy/basic_enemy.tscn")
const MOUSE_ENEMY = preload("res://entities/entity_list/mouse_enemy/mouse_enemy.tscn")
const RED_KNIGHT_ENEMY = preload("res://entities/entity_list/red_knight_enemy/red_knight_enemy.tscn")

const ENEMY_LIST: Array[Resource] = [BASIC_ENEMY, MOUSE_ENEMY, RED_KNIGHT_ENEMY]
const SUMMON_HEALTH_CANCEL: float = 24
const SUMMON_TIME: float = 4.0
const SUMMON_COOLDOWN: float = 3.0

var delta_count: float = 0.0
var just_summoned: bool = false
var warning_shown: bool = false
var enemy_list: Node3D
var spawn_index: int = 0
var summon_cancel_threshold: float = 0.0

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	just_summoned = false
	warning_shown = false
	
	enemy.action_animator.play("basic_enemy_animation_library/RESET")
	spawn_index = randi_range(0, enemy.enemy_positions.get_child_count() - 1)
	summon_cancel_threshold = enemy.health_component.current_health - SUMMON_HEALTH_CANCEL

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	if enemy.health_component.current_health <= summon_cancel_threshold:
		enemy.attack_indicator_animator.play("hide_indicator")
		return state_machine.change_state(&"Idle")
	
	if delta_count > SUMMON_TIME - 1.2 && !warning_shown:
		enemy.attack_indicator_animator.play("show_indicator")
		warning_shown = true
	
	if !just_summoned && delta_count >= SUMMON_TIME:
		enemy.play_sound_fx(enemy.sounds, &"summon")
		
		var new_enemy: Enemy = ENEMY_LIST.pick_random().instantiate()
		enemy.enemy_list.add_child(new_enemy)
		new_enemy.initialize_enemy(enemy.player, enemy.enemy_data, enemy.enemy_positions, enemy_list, enemy.projectiles)
		new_enemy.position = enemy.enemy_positions.get_child(spawn_index).position
		enemy.summoned_list.append(new_enemy)
		
		just_summoned = true
		delta_count = 0.0
		
		enemy.action_animator.play("basic_enemy_animation_library/attack")
		enemy.attack_indicator_animator.play("hide_indicator")
	
	if just_summoned && delta_count >= SUMMON_COOLDOWN:
		state_machine.change_state(&"Idle")
		return
