class_name AudioPlayerPool
extends RefCounted

var players: Array
var player_type: String
var bus_name: StringName
var _reserved: Array # players claimed but possibly not yet playing


func _init(count: int, type: String, bus: StringName, parent: Node = AudioManager):
	player_type = type
	bus_name = bus
	
	for i in count:
		var player
		match type:
			"AudioStreamPlayer":
				player = AudioStreamPlayer.new()
			"AudioStreamPlayer3D":
				player = AudioStreamPlayer3D.new()
			_:
				push_error("Unsupported player type: " + type)
				return
		
		player.name = type + str(i)
		player.bus = bus
		players.append(player)
		parent.add_child(player)
		player.finished.connect(_on_player_finished.bind(player))


func _on_player_finished(player) -> void:
	_reserved.erase(player)


func get_available_player():
	for player in players:
		if not player.playing and not _reserved.has(player):
			_reserved.append(player)
			return player
	
	print("Warning: All audio players in pool are currently in use. Consider increasing the pool size.")

	# If no free players, recycle the oldest one
	var oldest_player = players[0]
	var oldest_position = oldest_player.get_playback_position()
	
	for player in players:
		if player.playing:
			var position = player.get_playback_position()
			if position > oldest_position:
				oldest_position = position
				oldest_player = player
	
	return oldest_player


func play_sound(sound: AudioStream, volume: float = 0.0, pitch: float = 1.0, position: Vector3 = Vector3.ZERO):
	var player = get_available_player()
	if player:
		player.stop()
		player.stream = sound
		player.volume_db = volume
		player.pitch_scale = pitch
		
		if player is AudioStreamPlayer3D:
			player.position = position
		
		player.play()
	
	return player
