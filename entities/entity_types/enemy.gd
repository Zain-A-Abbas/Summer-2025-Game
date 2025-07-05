class_name Enemy
extends CharacterEntity

signal enemy_killed(enemy: Enemy)
signal enemy_damage_taken(enemy: Enemy, damage: int)

@onready var attack_indicator_animator: AnimationPlayer = %AttackIndicatorAnimator
@onready var action_animator: AnimationPlayer = %ActionAnimator
@onready var enemy_hp_bar: ProgressBar = %EnemyHPBar

@export var mesh: MeshInstance3D
@export var animation_tree: AnimationTree

var player: Player
var enemy_data: Node3D
var enemy_positions: Node3D
var enemy_list: Node3D
var projectiles: Node3D

func _ready() -> void:
	set_process(false)

func initialize_enemy(new_player: Player, data: Node3D, positions: Node3D, list: Node3D, projs: Node3D):
	if new_player:
		player = new_player
	if data:
		enemy_data = data
	if positions:
		enemy_positions = positions
	if list:
		enemy_list = list
	if projs:
		projectiles = projs
	
	enemy_hp_bar.max_value = health_component.max_health
	enemy_hp_bar.value = health_component.current_health
	enemy_damage_taken.connect(damage_taken)
	prepare_states()

func activate_enemy():
	set_process(true)

# Virtual function
func prepare_states():
	pass

func _on_hurtbox_hit_received(attack_object: AttackObject, invin: bool) -> void:
	pass

func damage_taken(enemy: Enemy, damage: int):
	enemy_hp_bar.value = health_component.current_health

func hurt_effect():
	mesh.set_instance_shader_parameter("hit_effect", true)
	await get_tree().create_timer(0.1).timeout
	mesh.set_instance_shader_parameter("hit_effect", false)

func show_attack_indicator():
	attack_indicator_animator.play("show_indicator")
	# play sound effect here
	
func hide_attack_indicator():
	attack_indicator_animator.play("hide_indicator")
