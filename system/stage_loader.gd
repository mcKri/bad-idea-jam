extends Node

@onready var game_world: Node3D = get_node("/root/GameWorld")
@onready var player: Player = game_world.get_node("Player")
@onready var car: Car = game_world.get_node("Car")

var worlds: Array[World] = [
	preload("res://stages/test_world/test_world.tres"),
]
var world_idx := -1
var stage_idx := -1
var stage: Stage


func _unhandled_input(event):
	if event.is_action_pressed("restart_stage"):
		restart_stage()


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
	car.process_mode = Node.PROCESS_MODE_INHERIT
	car.global_transform = stage.get_spawn_transform().translated(Vector3(0, 0.4, 0))
	
	# Initialize player
	player.process_mode = Node.PROCESS_MODE_INHERIT
	player.enter_car(car)
	
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


func restart_stage():
	load_stage(stage_idx)


func finish_stage():
	player.process_mode = Node.PROCESS_MODE_DISABLED
	car.process_mode = Node.PROCESS_MODE_DISABLED

	print("Stage finished!")
