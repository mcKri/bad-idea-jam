class_name AudioInstance
extends RefCounted

var _audio_player: Variant


func _init(audio_player: Variant) -> void:
	_audio_player = audio_player


func loop(should_loop: bool = true) -> AudioInstance:
	if _audio_player and is_instance_valid(_audio_player):
		_audio_player.stream.loop = should_loop
	return self


func set_pitch(pitch: float) -> AudioInstance:
	if _audio_player and is_instance_valid(_audio_player):
		_audio_player.pitch_scale = pitch
	return self


func randomize_pitch(min_pitch: float = 0.9, max_pitch: float = 1.1) -> AudioInstance:
	if _audio_player and is_instance_valid(_audio_player):
		_audio_player.pitch_scale = randf_range(min_pitch, max_pitch)
	return self


func set_volume(volume: float) -> AudioInstance:
	if _audio_player and is_instance_valid(_audio_player):
		_audio_player.volume_db = volume
	return self


func set_position(pos: Vector3) -> AudioInstance:
	if _audio_player and is_instance_valid(_audio_player) and _audio_player is AudioStreamPlayer3D:
		_audio_player.position = pos
	return self


func tween_volume(target_volume_db: float, duration: float, play_if_stopped: bool = false, stop_when_silent: bool = false) -> AudioInstance:
	if _audio_player and is_instance_valid(_audio_player):
		# Start playing if requested
		if play_if_stopped and not _audio_player.playing:
			_audio_player.play()
			
		# Create a tween to change the volume
		var tween: Tween = _audio_player.create_tween()
		tween.tween_property(_audio_player, "volume_db", target_volume_db, duration)
		
		# Stop when silent if requested
		if stop_when_silent and target_volume_db <= -60.0:
			tween.tween_callback(_audio_player.stop)
	return self


func attach_to_node(node: Node) -> AudioInstance:
	if _audio_player and is_instance_valid(_audio_player):
		node.tree_exited.connect(func():
			print("AudioInstance: Node exited tree, stopping audio.")
			if is_instance_valid(_audio_player):
				_audio_player.stop()
		)
	return self

	
# Convenience methods using tween_volume
func fade_in(duration: float, target_volume_db: float = 0.0) -> AudioInstance:
	if _audio_player and is_instance_valid(_audio_player):
		_audio_player.volume_db = -80.0 # Start silent
	return tween_volume(target_volume_db, duration, true, false)


func fade_out(duration: float, stop_when_done: bool = true) -> AudioInstance:
	return tween_volume(-80.0, duration, false, stop_when_done)


func stop() -> void:
	if _audio_player and is_instance_valid(_audio_player):
		_audio_player.stop()


func get_audio_player() -> Variant:
	return _audio_player


func is_playing() -> bool:
	if _audio_player and is_instance_valid(_audio_player):
		return _audio_player.playing
	return false
