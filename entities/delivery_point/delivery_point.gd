class_name DeliveryPoint
extends Node3D

const DEFAULT_BOX: PackedScene = preload("res://entities/box/box.tscn")

@onready var area: Area3D = $Area3D

@export var required_box: PackedScene = DEFAULT_BOX
var _required_box_instance: Box

signal delivered


func _on_area_3d_body_entered(body: Node3D):
	if body is Car:
		if body.box_anchor.get_top_box() != _required_box_instance:
			return

		body.box_anchor.deliver_box()
		area.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		delivered.emit()


func set_required_box(box: Box):
	_required_box_instance = box
