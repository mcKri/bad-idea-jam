extends Node

@onready var game_world: Node3D = get_node("/root/GameWorld")
@onready var car: Car = game_world.get_node("Car")

var curr_stage: Stage


func load_stage(stage_scene: PackedScene):
	if curr_stage:
		curr_stage.queue_free()
	
	curr_stage = stage_scene.instantiate()
	game_world.add_child(curr_stage)
	
	if not curr_stage.is_node_ready():
		await curr_stage.ready
	
	car.global_transform = curr_stage.get_spawn_transform().translated(Vector3(0, 0.4, 0))
	Camera.focus_on(car.camera_point)
	
	car.box_anchor.reset()
	for box in curr_stage.boxes:
		var box_instance = box.instantiate()
		car.box_anchor.add_box(box_instance)
