class_name DeliveryPoint
extends Node3D

const DEFAULT_BOX: PackedScene = preload("res://entities/box/box.tscn")

@onready var area: Area3D = $Area3D
@onready var sprite: Sprite3D = $Sprite3D
@onready var sub_viewport: SubViewport = $SubViewport

@export var required_box: PackedScene = DEFAULT_BOX
var _required_box_instance: Box

signal delivered


func _ready():
	set_active(false)


func _process(_delta):
	if Engine.is_editor_hint():
		var area_shape: BoxShape3D = area.shape
		sub_viewport.size = Vector2i(area_shape.size.x, area_shape.size.z)


func set_active(active: bool = true):
	sprite.visible = active
	var new_process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	area.set_deferred("process_mode", new_process_mode)


func _on_area_3d_body_entered(body: Node3D):
	if body is Car:
		if body.box_anchor.get_top_box() != _required_box_instance:
			return

		body.box_anchor.deliver_box()
		set_active(false)
		delivered.emit()


func set_required_box(box: Box):
	_required_box_instance = box
