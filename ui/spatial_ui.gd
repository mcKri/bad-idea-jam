@tool
class_name SpatialUI
extends CollisionObject3D

@export var sub_viewport: SubViewport

@onready var coll_shape: CollisionShape3D = $CollisionShape3D
@onready var sprite: Sprite3D = $Sprite3D


func _ready():
	input_event.connect(_on_input_event)


func _process(_delta):
	if Engine.is_editor_hint():
		var control_bounds: Vector2
		for child in sub_viewport.get_child(0).get_children():
			if child is Control:
				control_bounds = child.size
				break
		
		sub_viewport.size = control_bounds
		var box_shape := coll_shape.shape as BoxShape3D
		var bounds := control_bounds * sprite.pixel_size
		box_shape.size = Vector3(bounds.x, bounds.y, 0.01)


func _on_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int):
	var pos_3d := sprite.global_transform.affine_inverse() * event_position
	var pos_2d := Vector2(pos_3d.x, -pos_3d.y)

	var shape := coll_shape.shape as BoxShape3D
	var plane_size: Vector2 = Vector2(shape.size.x, shape.size.y)
	pos_2d += plane_size / 2
	pos_2d /= plane_size

	var viewport_pos := pos_2d * Vector2(sub_viewport.size)
	event.position = viewport_pos
	sub_viewport.push_input(event)
