class_name FlowerEnemyBombExplode
extends ProjectileState

var attack_object: AttackObject
var bomb: CSGSphere3D
var delta_count: float = 0.0
var active_time: float

func _init(new: CharacterEntity, model: CSGSphere3D, object: AttackObject) -> void:
	proj = new
	bomb = model
	attack_object = object

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	attack_object.show()
	proj.explosion_particles.emitting = true
	proj.model.visible = false
	proj.decal.visible = false
	
	attack_object.hitbox.monitorable = true
	active_time = proj.explosion_particles.lifetime * 0.45 # to match visuals

	proj.play_sound_fx(&"death")

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	attack_object.hitbox.monitorable = delta_count <= active_time
	
	if delta_count >= proj.explosion_duration:
		proj.char_entity_die()
