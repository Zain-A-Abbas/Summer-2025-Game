class_name Enemy
extends CharacterEntity


@onready var enemy_animation_player: AnimationPlayer = %EnemyAnimationPlayer
@onready var attack_indicator_animator: AnimationPlayer = %AttackIndicatorAnimator

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
	enemy_animation_player.play("hurt")
	resolve_hit(attack_object)

func get_direction_to_player(enemy: Enemy) -> Vector3:
	return enemy.position.direction_to(enemy.player.position)
	
func face_direction(enemy: Enemy, dir: Vector3) -> void:
	enemy.rotation.y = Vector2(-dir.x, dir.z).angle() + deg_to_rad(270)

func char_entity_die(args: Dictionary[String, Variant]  = {}):
	queue_free()
