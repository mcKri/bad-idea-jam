extends Node

const PLAYER_PACKED := preload("res://entities/player/player.tscn")
const CAR_PACKED := preload("res://entities/car/car.tscn")

@onready var game_world: Node3D = get_node("/root/GameWorld")

var worlds: Array[World] = [
	preload("res://stages/test_world/test_world.tres"),
]
var world_idx := -1
var stage_idx := -1
var stage: Stage
var player: Player
var car: Car


func load_stage(idx: int, new_world_idx: int = max(world_idx, 0)):
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
	car.global_transform = stage.get_spawn_transform().translated(Vector3(0, 0.4, 0))
	
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
	
	UILayer.hud.stage_timer.set_max_time(stage.time_limit)


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
		# TODO: Show end screen
		print("No more worlds!")
		return
	
	load_stage(0, next_idx)


func restart_stage():
	load_stage(stage_idx)


func fail_stage(reason: String = ""):
	player.input_enabled = false
	car.driving = false
	UILayer.stage_fail_screen.open(reason)


func complete_stage():
	player.input_enabled = false
	car.driving = false
	UILayer.stage_complete_screen.show()
