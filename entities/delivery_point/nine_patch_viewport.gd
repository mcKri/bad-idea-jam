@tool
extends SubViewport

@export var target: Node3D
@export_range(0.0001, 128.0) var pixel_size: float = 0.18


func _process(_delta):
	if Engine.is_editor_hint():
		if target:
			if target is CollisionShape3D:
				var shape = target.shape
				if shape is BoxShape3D:
					size = Vector2i(shape.size.x / pixel_size, shape.size.z / pixel_size)
