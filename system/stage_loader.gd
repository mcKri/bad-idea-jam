extends Node

const PLAYER_PACKED := preload("res://entities/player/player.tscn")
const CAR_PACKED := preload("res://entities/car/car.tscn")

@onready var game_world: Node3D = get_node("/root/GameWorld")

var worlds: Array[World] = [
	preload("res://stages/world_1/world_1.tres"),
	preload("res://stages/world_2/world_2.tres"),
]
var world_idx := -1
var stage_idx := -1
var stage: Stage
var player: Player
var car: Car


func _ready():
	SaveSystem.save_started.connect(_on_save_started)


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
	
	AudioManager.play_music(stage.music)
	UILayer.hud.minigame_handler.reset()
	UILayer.hud.stage_timer.set_max_time(stage.time_limit)
	UILayer.hud.show()

	stage.active = true


func advance_stage():
	var world := worlds[world_idx]
	var next_idx := stage_idx + 1
	if next_idx >= world.stages.size():
		advance_world()
		return
	
	load_stage(next_idx)


func advance_world():
	var next_idx := world_idx + 1
	if next_idx >= worlds.size():
		stage.hide()
		stage.queue_free()
		UILayer.game_end_screen.show()
		return
	
	load_stage(0, next_idx)


func restart_stage():
	load_stage(stage_idx)


func fail_stage(reason: String = ""):
	player.input_enabled = false
	car.driving = false
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
	stage.active = false


func _on_save_started():
	SaveSystem.set_property("world", world_idx)
	SaveSystem.set_property("stage", stage_idx)
	SaveSystem.resolve_save_connection(_on_save_started)
	print("StageLoader save complete")
