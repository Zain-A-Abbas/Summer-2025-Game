class_name Enemy
extends CharacterEntity


@onready var attack_indicator_animator: AnimationPlayer = %AttackIndicatorAnimator
@onready var action_animator: AnimationPlayer = %ActionAnimator

@export var mesh: MeshInstance3D
@export var animation_tree: AnimationTree

static var player: Player

func _ready() -> void:
	if !player:
		var new_player: Player = get_tree().get_first_node_in_group("player")
		if new_player:
			player = new_player
	
	prepare_states()

# Virtual function
func prepare_states():
	pass

func _on_hurtbox_hit_received(attack_object: AttackObject) -> void:
	#shader_animator.play("hurt")
	hurt_effect()
	resolve_hit(attack_object)

func hurt_effect():
	mesh.set_instance_shader_parameter("hit_effect", true)
	await get_tree().create_timer(0.1).timeout
	mesh.set_instance_shader_parameter("hit_effect", false)

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	queue_free()
