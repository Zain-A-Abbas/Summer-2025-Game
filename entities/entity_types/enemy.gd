class_name Enemy
extends CharacterEntity

@onready var enemy_animation_player: AnimationPlayer = %EnemyAnimationPlayer

func _ready() -> void:
	prepare_states()

# Virtual function
func prepare_states():
	pass


func _on_hurtbox_area_entered(area: Area3D) -> void:
	enemy_animation_player.play("hurt")
	resolve_hit(area)

func resolve_hit(attack_area: Area3D):
	if attack_area is AttackHitbox:
		var attack_object: AttackObject = attack_area.attack_object
		var attack_effects: Array[AttackEffect] = attack_object.attack_effects
		for effect in attack_effects:
			effect.apply_effect(self)
