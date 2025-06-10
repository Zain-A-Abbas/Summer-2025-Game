class_name HurtboxComponent
extends Area3D

signal hit_received(attack_object: AttackObject)

var invincibility_frames: bool = false

func _on_area_entered(area: Area3D) -> void:
	# Over here maybe do something like an ability which gives you a bonus for i-framing through an attack
	# Or attacks which can ignore i-frames and force a parry
	
	if invincibility_frames:
		return
	
	if area is AttackHitbox:
		hit_received.emit(area.attack_object)
