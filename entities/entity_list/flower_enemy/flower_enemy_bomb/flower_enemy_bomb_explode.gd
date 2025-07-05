class_name FlowerEnemyBombExplode
extends ProjectileState

const EXPLOSION_TIME: float = 1.05

var delta_count: float = 0
var attack_object: AttackObject
var bomb: CSGSphere3D

func _init(new: CharacterEntity, model: CSGSphere3D, object: AttackObject) -> void:
	proj = new
	bomb = model
	attack_object = object

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0
	attack_object.hitbox.show()
	attack_object.hitbox.monitorable = true

	proj.play_sound_fx(proj.sounds, &"explode")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	if delta_count >= EXPLOSION_TIME:
		return proj.char_entity_die()
