class_name ControlShakeComponent
extends Node

# Position of parent
var base_position: Vector2 = Vector2.ZERO
# Intensity of trauma. Every whole number of trauma means number of pixels moved
var trauma_intensity: float = 0.0
# trauma_reduction is deducted from trauma_intensity every second
var trauma_reduction: float = 0.0

@export var parent: Control
@export var horizontal: bool = true
@export var vertical: bool = true

func _ready():
	await owner.ready

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if trauma_intensity > 0.0:
		trauma_process(delta)

func trauma_process(delta: float):
	trauma_intensity = clamp(trauma_intensity - trauma_reduction * delta, 0.0, trauma_intensity)
	if trauma_intensity == 0.0:
		trauma_reduction = 0.0
	parent.position.x = base_position.x + int(horizontal) * trauma_intensity * (randf() * 2.0 - 1.0)
	parent.position.y = base_position.y + int(vertical) * trauma_intensity * (randf() * 2.0 - 1.0) / 2.0

func begin_trauma(intensity: float, reduction: float):
	if trauma_intensity == 0.0:
		base_position = parent.position
	trauma_intensity += intensity
	trauma_reduction += reduction

func stop_trauma():
	trauma_intensity = 0.0
