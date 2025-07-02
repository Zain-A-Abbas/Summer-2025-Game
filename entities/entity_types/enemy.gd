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

func _ready() -> void:
	set_process(false)

func initialize_enemy(new_player: Player):
	if new_player:
		player = new_player
	
	enemy_hp_bar.max_value = health_component.max_health
	enemy_hp_bar.value = health_component.current_health
	enemy_damage_taken.connect(damage_taken)
	prepare_states()

func activate_enemy():
	set_process(true)

# Virtual function
func prepare_states():
	pass

func _on_hurtbox_hit_received(attack_object: AttackObject) -> void:
	#shader_animator.play("hurt")
	hurt_effect()
	resolve_hit(attack_object)

func damage_taken(enemy: Enemy, damage: int):
	enemy_hp_bar.value = health_component.current_health

func hurt_effect():
	mesh.set_instance_shader_parameter("hit_effect", true)
	await get_tree().create_timer(0.1).timeout
	mesh.set_instance_shader_parameter("hit_effect", false)

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	enemy_killed.emit(self)
	queue_free()
