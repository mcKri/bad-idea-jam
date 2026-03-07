class_name Stage
extends Node3D

@onready var spawn_point: Marker3D = $SpawnPoint
@onready var delivery_point_holder: Node3D = $DeliveryPoints


func get_spawn_transform() -> Transform3D:
	if spawn_point:
		return spawn_point.global_transform
	
	return Transform3D.IDENTITY


func get_delivery_points() -> Array[DeliveryPoint]:
	var points: Array[DeliveryPoint] = []
	for child in delivery_point_holder.get_children():
		if child is DeliveryPoint:
			points.append(child)
	
	return points
