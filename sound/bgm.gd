extends Node

# If one is played right before a battle begins then place it in Battle

enum BGM_TYPE{
	NONE,
	TITLE,
	BATTLE,
	BOSS,
	HEALING,
	SHOP
}

const BGMS: Dictionary[BGM_TYPE, Resource] = {
	BGM_TYPE.NONE: null,
	BGM_TYPE.TITLE: preload("res://sound/music/04 DSGNDron, Dungeon, Ambience, Drone, Dark, Loop.wav"),
	BGM_TYPE.BATTLE: preload("res://sound/music/Torch Impact 2.wav"),
	BGM_TYPE.BOSS: preload("res://sound/music/Water Jump.wav"),
	BGM_TYPE.HEALING: preload("res://sound/music/Forest Night.ogg"),
	BGM_TYPE.SHOP: preload("res://sound/music/Wood Chain Run 1.wav")
}

# Functionality
const MIN_DB := -80.0
const MAX_DB := -8.0

class BackgroundMusic extends Node:
	var bgm_player: AudioStreamPlayer
	var is_playing: bool
	
	var current_volume: float = 1.0
	
	func _init():
		bgm_player = AudioStreamPlayer.new()
		bgm_player.volume_db = MIN_DB
		add_child(bgm_player)
		bgm_player.finished.connect(loop)
	
	# This volume is applied -before- taking settings into account
	func set_volume(new_vol: float):
		bgm_player.volume_db = Bgm.get_audio_db(new_vol)
	
	func loop():
		bgm_player.seek(0.0)
		bgm_player.play()
	
	func play(audio_stream: AudioStream, bgm_db: float):
		if audio_stream:
			bgm_player.stream = audio_stream
			bgm_player.volume_db = bgm_db
			bgm_player.play()
			is_playing = true
	
	func stop():
		is_playing = false
		bgm_player.stop()
	
	func pause():
		is_playing = false
		bgm_player.stream_paused = true
		
	func unpause():
		is_playing = true
		bgm_player.stream_paused = false
	

var current_bgm: BGM_TYPE
var bgm_player: BackgroundMusic


func _ready() -> void:
	bgm_player = BackgroundMusic.new()
	add_child(bgm_player)

func play_bgm(bgm: BGM_TYPE, volume: float = 1.0):
	current_bgm = bgm
	bgm_player.play(BGMS[current_bgm], get_audio_db(volume))
 
func pause_bgm():
	bgm_player.pause()

func unpause_bgm():
	bgm_player.unpause()
 
func stop_bgm():
	bgm_player.stop()

func fadeout_bgm(fadeout_time: float = 0.5):
	if bgm_player == null:
		return
	var fade_tween: Tween = create_tween()
	var prev_volume: float = bgm_player.current_volume
	fade_tween.tween_method(
		change_volume,
		prev_volume,
		0.0,
		fadeout_time
	)
	await fade_tween.finished

func unload_bgm():
	bgm_player = null
	current_bgm = BGM_TYPE.NONE

# Called when the bgm sound is changed by the player in settings 
func bgm_setting_changed():
	if bgm_player != null:
		change_volume(bgm_player.current_volume)

# Changing the volume of the bgm player
func change_volume(new_volume: float):
	if bgm_player != null:
		bgm_player.set_volume(new_volume)

# Calculates the decibel scale of the audio
func get_audio_db(volume: float = 1.0):
	var audio_scale: float = 0.7 * volume # * Settings.bgm_audio * Settings.master_audio 
	var _db: float = -48.0 + 6.0 * (log(100.0 * audio_scale) / log(2))
	return _db
