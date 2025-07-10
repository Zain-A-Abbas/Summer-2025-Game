class_name DeathState
extends State

var char: CharacterEntity
var animation_name: String
var duration: float
var delta_count: float = 0.0


func _init(new_char: CharacterEntity, anim_name: String, time: float):
	char = new_char
	animation_name = anim_name
	duration = time

func enter_state(previous_state: State, args: Dictionary[String, Variant]):
	delta_count = 0.0
	if char is Enemy:
		char.enemy_hp_sprite.visible = false
	
	# only play death sound for enemies spawned naturally
	if !args.has("summoned") || (args.has("summoned") && !args["summoned"]):
		char.play_sound_fx(&"death")
	
	char.action_animator.play(animation_name)
	char.set_collision_layer_value(1, 0)

func st_physics_process(delta: float) -> void:
	delta_count += delta
	
	if delta_count >= duration:
		char.queue_free()
