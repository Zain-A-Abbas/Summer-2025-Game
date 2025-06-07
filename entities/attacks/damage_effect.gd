class_name DamageEffect
extends AttackEffect

@export var damage: int = 1

func apply_effect(target: Node3D):
	print(damage)
