class_name HurtboxComponent
extends Area3D

signal hit_parried(attack_object: AttackObject)
signal hit_received(attack_object: AttackObject, invin: bool)

var invincibility_frames: bool = false
var parry_frames: bool = false

func _on_area_entered(area: Area3D) -> void:
	# Over here maybe do something like an ability which gives you a bonus for i-framing through an attack
	# Or attacks which can ignore i-frames and force a parry
	
	if area is AttackHitbox:
		var attack: AttackObject = area.attack_object
		if parry_frames:
			hit_parried.emit(attack)
		else:
			hit_received.emit(area.attack_object, invincibility_frames)
