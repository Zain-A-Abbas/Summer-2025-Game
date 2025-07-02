@tool
extends Marker3D
class_name Pickup

@onready var pickup_model: Node3D = %PickupModel

const ACCELERATION: float = 0.4
const MIN_DISTANCE_SQUARED: float = 1.0
const DELETE_TIMER: float = 0.5

@export var rotate: bool = true

var delete_tracking: float = 0.0
var picked_up: bool = false
var velocity: float = 0.0
var rotate_speed: float = 1.0
var chasing_player: bool = false
var player: Player

func _physics_process(delta: float) -> void:
	if rotate:
		pickup_model.rotation.y += delta * rotate_speed
	
	if chasing_player:
		delete_tracking += delta
		velocity += ACCELERATION
		scale -= Vector3(delta, delta, delta) * 0.5
		position = position.move_toward(player.position, velocity * delta)
		if delete_tracking >= DELETE_TIMER:
			if position.distance_squared_to(player.position) < MIN_DISTANCE_SQUARED:
				queue_free()

func pickup_effect(player: Player):
	print("Abstract pickup effect")

func pickup_visual_effect(player: Player):
	rotate_speed *= 2.0
	chasing_player = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if picked_up:
		return
	picked_up = true
	
	if body is Player:
		player = body
		pickup_visual_effect(player)
		pickup_effect(player)
	else:
		push_error("Pickup detected non-player")
