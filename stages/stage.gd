class_name Stage
extends Node3D

@onready var spawn_point: Marker3D = $SpawnPoint
@onready var delivery_point_holder: Node3D = $DeliveryPoints

var delivery_points: Array[DeliveryPoint] = []
var curr_delivery_idx: int = 0


func _ready():
	for child in delivery_point_holder.get_children():
		if child is DeliveryPoint:
			delivery_points.append(child)
			child.delivered.connect(_on_delivery_point_delivered)
	
	activate_next_delivery_point()


func activate_next_delivery_point():
	var next_point := delivery_points[curr_delivery_idx]
	next_point.set_active()


func complete_delivery():
	if curr_delivery_idx + 1 >= delivery_points.size():
		StageLoader.complete_stage()
		return
	
	curr_delivery_idx += 1
	activate_next_delivery_point()


func get_spawn_transform() -> Transform3D:
	if spawn_point:
		return spawn_point.global_transform
	
	return Transform3D.IDENTITY


func _on_delivery_point_delivered():
	complete_delivery()
