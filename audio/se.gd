extends Node


# Functionality

const MIN_DB := -80.0
const MAX_DB := -8.0
# Number of sound effects that can play at once
const QUEUE_SIZE = 10
const SOUND_EFFECT_FOLDER = "res://audio/sounds/"

var sound_queue = []
var next_sound = 0


func _ready():
	_init_stream_players()

func _physics_process(delta: float) -> void:
	pass

func _init_stream_players():
	for i in range(QUEUE_SIZE):
		var se_player = AudioStreamPlayer.new()
		add_child(se_player)
		sound_queue.append(se_player)

func _get_next_index():
	var next = next_sound
	next_sound = (next_sound + 1) % QUEUE_SIZE
	return next

func sound_effect(sound_name: String, volume: float = 1.0, pitch: float = 1.0, menu_audio: bool = false):
	var sound_effect_path = SOUND_EFFECT_FOLDER + sound_name + ".wav"
	#assert(FileAccess.file_exists(sound_effect_path), "Sound file not found.")
	play_se(load(sound_effect_path), volume, menu_audio, pitch)

func play_se(sound, volume: float = 1.0, menu_audio: bool = false, pitch: float = 1.0, args: Dictionary = {}): # Sound is a file
	var index = _get_next_index()
	var se_player: AudioStreamPlayer
	if !args.has("typing"):
		se_player = sound_queue[index]
	else:
		se_player = AudioStreamPlayer.new()
		add_child(se_player)
	se_player.volume_db = get_audio_db(volume, menu_audio)
	se_player.stream = sound
	se_player.pitch_scale = pitch
	duplicate_sound(sound)
	se_player.play()
	if args.has("typing"):
		await se_player.finished
		se_player.queue_free()

func stop_se():
	var se_player: AudioStreamPlayer = sound_queue[next_sound]
	se_player.stop()


# Calculates the decibel scale of the audio
func get_audio_db(volume: float = 1.0, menu_audio: bool = false):
	var audio_scale: float = volume
	var _db: float = -48.0 + 6.0 * (log(100.0 * audio_scale) / log(2))
	return _db

# Checks any duplicate sounds and stops them from playing
func duplicate_sound(new_sound):
	if !no_repeat_sounds.has(new_sound):
		return
	for se_player in sound_queue:
		if se_player.stream == new_sound:
			se_player.stop()

var no_repeat_sounds: Array = []

# COMMON SOUNDS - Sounds that will be playing a lot, so I'm making functions to hasten their calling
# Why the fuck did my manner of speed deteriorate into talking like a medieval guard

func ui_confirm():
	sound_effect("UIConfirm", 1.0, 1.0, true)

func ui_scroll():
	sound_effect("UIScroll", 1.0, 1.0, true)
