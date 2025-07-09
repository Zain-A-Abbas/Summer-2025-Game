class_name FlowerEnemyBombExplode
extends ProjectileState

var attack_object: AttackObject
var bomb: CSGSphere3D
var delta_count: float = 0.0


func _init(new: CharacterEntity, model: CSGSphere3D, object: AttackObject) -> void:
	proj = new
	bomb = model
	attack_object = object

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0
	attack_object.show()
	attack_object.hitbox.monitorable = true

	proj.play_sound_fx(&"death")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	if delta_count >= proj.explosion_duration:
		attack_object.hitbox.monitorable = false
		proj.char_entity_die()
