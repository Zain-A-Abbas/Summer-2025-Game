extends Camera3D
class_name LevelCamera

enum CameraState {
	FOLLOW_PLAYER
}

const ROTATION: Vector3 = Vector3(-45.0, -135.0, 0.0)
const FOLLOW_SPEED: float = 10.0
const DISTANCE: float = 10.0
const MAX_OFFSET: float = 10.0

var camera_state: CameraState = CameraState.FOLLOW_PLAYER

var player: Player

func initialize(_player: Player):
	player = _player
	rotation.x = deg_to_rad(ROTATION.x)
	rotation.y = deg_to_rad(ROTATION.y)
	rotation.z = deg_to_rad(ROTATION.z)
	position = getDestination()

func _physics_process(delta: float) -> void:
	if camera_state == CameraState.FOLLOW_PLAYER && player:
		followPlayer(delta)

func followPlayer(delta: float):
	var destination: Vector3 = getDestination()
	position = position.lerp(destination, 0.5)

func getDestination() -> Vector3:
	return player.position + Vector3(-0.5, 1, -0.5).normalized() * DISTANCE
