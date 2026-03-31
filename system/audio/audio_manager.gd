extends Node

const POOL_SIZE: int = 64
const INTERNAL_COOLDOWN_TIME: float = 0.05

var sfx_pool: AudioPlayerPool
var sfx_3d_pool: AudioPlayerPool
var ui_pool: AudioPlayerPool

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var jingle_player: AudioStreamPlayer = $JinglePlayer

var _music_position: float = 0.0
var _music_volume_linear: float = 1.0

var _sounds_on_cooldown: Dictionary[AudioStream, float] = {}


func _ready() -> void:
	_initialize_audio_pools()


func _process(delta: float):
	# Update cooldowns
	var keys := _sounds_on_cooldown.keys()
	for sound in keys:
		_sounds_on_cooldown[sound] -= delta
		if _sounds_on_cooldown[sound] <= 0.0:
			_sounds_on_cooldown.erase(sound)


func _initialize_audio_pools() -> void:
	sfx_pool = AudioPlayerPool.new(POOL_SIZE, "AudioStreamPlayer", &"SFX")
	sfx_3d_pool = AudioPlayerPool.new(POOL_SIZE, "AudioStreamPlayer3D", &"SFX")
	ui_pool = AudioPlayerPool.new(POOL_SIZE, "AudioStreamPlayer", &"UI")


func play_sound(sound: AudioStream, volume: float = 0.0) -> AudioInstance:
	if _sounds_on_cooldown.has(sound):
		return null
	
	var player = sfx_pool.play_sound(sound, volume) as AudioStreamPlayer
	_sounds_on_cooldown[sound] = INTERNAL_COOLDOWN_TIME
	
	return AudioInstance.new(player)


func play_sound_3d(sound: AudioStream, pos: Vector3, volume: float = 0.0) -> AudioInstance:
	if _sounds_on_cooldown.has(sound):
		print("SKIPPING")
		return null
	
	var player = sfx_3d_pool.play_sound(sound, volume, 1.0, pos) as AudioStreamPlayer3D
	_sounds_on_cooldown[sound] = INTERNAL_COOLDOWN_TIME
	print("PLAYING")
	
	return AudioInstance.new(player)


func play_ui_sound(sound: AudioStream, volume: float = 0.0) -> AudioInstance:
	if _sounds_on_cooldown.has(sound):
		return null
	
	var player = ui_pool.play_sound(sound, volume) as AudioStreamPlayer
	_sounds_on_cooldown[sound] = INTERNAL_COOLDOWN_TIME
	
	return AudioInstance.new(player)


func play_music(music: AudioStream, fade_time: float = 0.0, preserve_position: bool = false) -> AudioStreamPlayer:
	if music_player.stream != music:
		var start_position := music_player.get_playback_position() if preserve_position else 0.0
		if fade_time > 0:
			var new_player: AudioStreamPlayer = music_player.duplicate()
			new_player.stream = music
			new_player.pitch_scale = 1.0
			new_player.volume_linear = 0.0
			add_child(new_player)
			
			new_player.play(start_position)

			var target_volume: float = _music_volume_linear
			var tween := create_tween()
			var old_player := music_player
			
			tween.tween_property(new_player, "volume_linear", target_volume, fade_time)
			tween.set_parallel()
			tween.tween_property(music_player, "volume_linear", 0.0, fade_time)
			tween.finished.connect(func():
				old_player.stop()
				old_player.queue_free()
			)

			music_player = new_player
		else:
			music_player.stream = music
			music_player.pitch_scale = 1.0
			music_player.play(start_position)
	
	return music_player


func get_current_music() -> AudioStream:
	return music_player.stream


func play_jingle(jingle: AudioStream) -> void:
	pause_music(true)
	jingle_player.stream = jingle
	jingle_player.play()


func pause_music(should_pause: bool = true) -> void:
	if should_pause:
		_music_position = music_player.get_playback_position()
		music_player.stop()
	else:
		jingle_player.stop()
		music_player.play(_music_position)
