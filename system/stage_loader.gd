extends Node

@onready var game_world: Node3D = get_node("/root/GameWorld")
@onready var player: Player = game_world.get_node("Player")
@onready var car: Car = game_world.get_node("Car")

var curr_stage: Stage


func load_stage(stage_scene: PackedScene):
	if curr_stage:
		curr_stage.queue_free()
	
	curr_stage = stage_scene.instantiate()
	game_world.add_child(curr_stage)
	
	if not curr_stage.is_node_ready():
		await curr_stage.ready
	
	# Reposition car at spawn point
	car.global_transform = curr_stage.get_spawn_transform().translated(Vector3(0, 0.4, 0))
	
	player.enter_car(car)
	
	# Initialize delivery points
	var boxes: Array[Box] = []
	var delivery_points := curr_stage.delivery_points
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


func finish_stage():
	print("Stage finished!")
