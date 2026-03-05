class_name Stage
extends Node3D

@onready var spawn_point: Marker3D = $SpawnPoint

@export var boxes: Array[PackedScene]


func get_spawn_transform() -> Transform3D:
	if spawn_point:
		return spawn_point.global_transform
	
	return Transform3D.IDENTITY
