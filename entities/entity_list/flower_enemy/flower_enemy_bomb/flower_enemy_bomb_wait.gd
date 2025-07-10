class_name FlowerEnemyBombWait
extends ProjectileState

var delta_count: float = 0.0
var bomb: CSGSphere3D # temporary
var bomb_entity: FlowerEnemyBomb

var ticking: int = -1

func _init(new: FlowerEnemyBomb, model: CSGSphere3D) -> void:
	proj = new
	bomb_entity = new
	bomb = model

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	bomb.show()

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	bomb_entity.global_position = bomb_entity.global_position.move_toward(
		Vector3(
			bomb_entity.goal_position.x,
			bomb_entity.global_position.y,
			bomb_entity.goal_position.z),
		FlowerEnemyBomb.BOMB_HORIZONTAL_VELOCITY * delta)
	
	bomb_entity.global_position.y += bomb_entity.bomb_velocity.y * delta
	bomb_entity.bomb_velocity.y -= bomb_entity.BOMB_GRAVITY * delta
	if bomb_entity.global_position.y < bomb_entity.goal_position.y:
		bomb_entity.bomb_velocity = Vector3.ZERO
		bomb_entity.global_position.y = bomb_entity.goal_position.y
	
	if delta_count >= proj.time_to_live * 0.5:
		ticking = wrapi(ticking + 1, 0, 8)
		if ticking == 0:
			bomb_entity.model.set_instance_shader_parameter("ticking", true)
		elif ticking == 4:
			bomb_entity.model.set_instance_shader_parameter("ticking", false)
	
	if delta_count >= proj.time_to_live:
		return state_machine.change_state(&"Explode")
