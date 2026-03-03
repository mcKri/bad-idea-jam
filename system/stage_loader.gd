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
	
	car.global_position = curr_stage.get_spawn_position()
	Camera.focus_on(car.mesh)
