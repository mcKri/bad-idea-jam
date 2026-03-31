extends Node

const PLAYER_PACKED := preload("res://entities/player/player.tscn")
const CAR_PACKED := preload("res://entities/car/car.tscn")
const MUSIC_POOL := [
	preload("res://assets/music/gj_1.2.mp3"),
	preload("res://assets/music/gj_3.2.mp3"),
	preload("res://assets/music/gj_4.1.mp3"),
]

@onready var game_world: Node3D = get_node("/root/GameWorld")

var worlds: Array[World] = [
	preload("res://stages/world_1/world_1.tres"),
	preload("res://stages/world_2/world_2.tres"),
	preload("res://stages/world_3/world_3.tres"),
]
var world_idx := -1
var stage_idx := -1
var stage: Stage
var player: Player
var car: Car
@onready var _music: AudioStream = pick_random_music()


func _ready():
	SaveSystem.save_started.connect(_on_save_started)


# func _input(event):
# 	if event.is_action_pressed("next_level"):
# 		advance_stage()
# 	elif event.is_action_pressed("prev_level"):
# 		var prev_idx := stage_idx - 1
# 		var new_world_idx := world_idx
# 		if prev_idx < 0:
# 			new_world_idx -= 1
# 			if new_world_idx < 0:
# 				return
# 			prev_idx = worlds[new_world_idx].stages.size() - 1
		
# 		load_stage(prev_idx, new_world_idx)


func load_stage(idx: int, new_world_idx: int = max(world_idx, 0)):
	SaveSystem.save_game()

	if stage:
		stage.queue_free()
	
	world_idx = new_world_idx
	stage_idx = idx
	var world := worlds[world_idx]
	stage = world.stages[idx].instantiate()
	
	game_world.add_child(stage)
	if not stage.is_node_ready():
		await stage.ready
	
	# Initialize car
	car = CAR_PACKED.instantiate()
	stage.add_child(car)
	var spawn_transform := stage.get_spawn_transform()
	car.global_transform = spawn_transform.translated(Vector3(0, 1.0, 0))
	car.mesh.global_basis = spawn_transform.basis
	car.sync_visual_state()
	
	# Initialize player
	player = PLAYER_PACKED.instantiate()
	stage.add_child(player)
	player.enter_car(car)
	Camera.set_target(car.camera_point, INF)
	
	# Initialize delivery points
	var boxes: Array[Box] = []
	var delivery_points := stage.delivery_points
	for i in range(delivery_points.size()):
		var point := delivery_points[i]
		var box_instance = point.required_box.instantiate()
		point.set_required_box(box_instance)
		boxes.append(box_instance)
	
	# Add boxes to car in reverse order so they stack correctly
	boxes.reverse()
	car.box_anchor.reset()
	for box in boxes:
		car.box_anchor.add_box(box)
	
	AudioManager.play_music(_music)
	UILayer.hud.minigame_handler.reset()
	UILayer.hud.stage_timer.set_max_time(stage.time_limit)
	UILayer.hud.show()
	UILayer.hud.stage_indicator.display(world_idx, worlds.size(), stage_idx, worlds[world_idx].stages.size())

	stage.active = true


func advance_stage():
	if stage:
		stage.active = false

	UILayer.transition_overlay.trigger()
	await UILayer.transition_overlay.halfway

	var world := worlds[world_idx]
	var next_idx := stage_idx + 1
	if next_idx >= world.stages.size():
		advance_world()
		return
	
	_music = pick_random_music()
	load_stage(next_idx)

	await UILayer.transition_overlay.finished
	if stage:
		stage.active = true


func advance_world():
	var next_idx := world_idx + 1
	if next_idx >= worlds.size():
		stage.hide()
		stage.queue_free()
		UILayer.game_end_screen.show()
		return
	
	_music = pick_random_music()
	load_stage(0, next_idx)


func restart_stage():
	load_stage(stage_idx)


func fail_stage(reason: String = ""):
	if is_instance_valid(player):
		player.input_enabled = false
	if is_instance_valid(car):
		car.driving = false
		car.destroy()
	UILayer.stage_fail_screen.open(reason)
	UILayer.hud.minigame_handler.set_paused(true)
	AudioManager.play_music(preload("res://assets/music/game_over.mp3"))
	stage.active = false


func complete_stage():
	player.hide()
	player.queue_free()
	car.hide()
	car.queue_free()
	UILayer.hud.hide()
	UILayer.hud.minigame_handler.set_paused(true)
	stage.active = false


func pick_random_music() -> AudioStream:
	var new_music: AudioStream = MUSIC_POOL.pick_random()
	while new_music == _music:
		new_music = MUSIC_POOL.pick_random()
	
	return new_music


func _on_save_started():
	SaveSystem.set_property("world", world_idx)
	SaveSystem.set_property("stage", stage_idx)
	SaveSystem.resolve_save_connection(_on_save_started)
	print("StageLoader save complete")
