extends Node3D

func _ready():
	await SaveSystem.load_game()

	var world_idx: int = SaveSystem.get_property("world")
	var stage_idx: int = SaveSystem.get_property("stage")
	print("Loaded save data: world=" + str(world_idx) + ", stage=" + str(stage_idx))
	StageLoader.load_stage(stage_idx, world_idx)
