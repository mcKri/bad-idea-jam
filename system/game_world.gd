extends Node3D

@export var initial_level: PackedScene


func _ready():
	if initial_level:
		StageLoader.load_stage(initial_level)
