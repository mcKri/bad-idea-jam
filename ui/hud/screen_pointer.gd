class_name ScreenPointer
extends Control

const HIDE_THRESHOLD: float = 10.0
const POINTER_MARGIN: float = 150.0

@onready var pointer_template: TextureRect = $ArrowTemplate
@onready var pointer_texture: Texture = preload("res://ui/hud/screen_pointer/arrow.png")

var target_datas: Array[Dictionary] = []
var target_pointers: Dictionary[Node3D, Control] = {}
var center_node: Node3D = null


func _ready():
	pointer_template.hide()
	_center_pointer(pointer_template)


func _center_pointer(pointer: Control):
	pointer.pivot_offset = pointer.size * pointer.scale / 2
	var pointer_attachment: TextureRect = pointer.get_node("TextureRect")
	if pointer_attachment:
		pointer_attachment.pivot_offset = pointer_attachment.size / 2


func _process(_delta):
	_draw_pointers()


func set_center_node(node: Node3D):
	center_node = node


func add_target(target: Node3D, image: Texture = null):
	target_datas.append({
		"node": target,
		"image": image,
	})


func remove_target(target: Node3D):
	var target_data = null
	for data in target_datas:
		if data.node == target:
			target_data = data
			break
	if !target_data:
		return
	
	_erase_target_data(target_data)


func _erase_target_data(target_data: Dictionary):
	var target: Node3D = target_data.get("node", null)
	if target_pointers.has(target):
		var pointer: TextureRect = target_pointers[target]
		pointer.queue_free()
		target_pointers.erase(target)
	
	target_datas.erase(target_data)


func _draw_pointers():
	var camera := get_viewport().get_camera_3d()
	if not camera:
		return

	var control_origin := get_global_rect().position
	var center := size / 2
	if center_node and is_instance_valid(center_node):
		center = camera.unproject_position(center_node.global_position) - control_origin

	var bounds_rect := Rect2(center - Vector2.ONE * POINTER_MARGIN, Vector2.ONE * POINTER_MARGIN * 2)

	for target_data in target_datas:
		if not _validate_target_data(target_data):
			target_datas.erase(target_data)
			continue

		var node: Node3D = target_data.node
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			remove_target(node)
			continue

		# Get or create pointer
		var pointer: TextureRect = target_pointers.get(node, null)
		if not pointer:
			pointer = pointer_template.duplicate()
			if node.tree_exited.is_connected(_remove_pointer.bind(pointer)):
				node.tree_exited.disconnect(_remove_pointer.bind(pointer))
			node.tree_exited.connect(_remove_pointer.bind(pointer))
			
			add_child(pointer)
			target_pointers[node] = pointer

		pointer.show()
		
		# Display image if available
		var pointer_attachment: TextureRect = pointer.get_node("TextureRect")
		if target_data.image:
			pointer_attachment.texture = target_data.image
		else:
			pointer_attachment.hide()

		# Project 3D world position to screen, then convert to control-local space
		var world_pos: Vector3 = node.global_position
		var screen_pos: Vector2 = camera.unproject_position(world_pos)
		var local_pos: Vector2 = screen_pos - control_origin

		var in_front := camera.is_position_in_frustum(world_pos)
		var is_behind_camera := (world_pos - camera.global_position).dot(camera.global_transform.basis.z) > 0
		var any_corner_visible := in_front and bounds_rect.grow(-HIDE_THRESHOLD).has_point(local_pos)

		if any_corner_visible:
			pointer.hide()
			continue

		# When behind the camera, unproject_position gives mirrored coords — flip the direction
		var dir: Vector2
		if is_behind_camera:
			dir = - (local_pos - center).normalized()
		else:
			dir = (local_pos - center).normalized()
		if dir == Vector2.ZERO:
			dir = Vector2.DOWN

		var margin: float = (pointer.size * pointer.scale).length() / 2
		var half_size = Vector2(POINTER_MARGIN, POINTER_MARGIN) - Vector2(margin, margin)
		var pointer_pos = center

		# Find intersection with rectangle bounds
		var t_max = INF
		for i in 2:
			if abs(dir[i]) > 0.001:
				var t = half_size[i] / abs(dir[i])
				t_max = min(t_max, t)
		pointer_pos += dir * t_max

		# Clamp to rectangle
		pointer_pos.x = clamp(pointer_pos.x, center.x - POINTER_MARGIN + margin, center.x + POINTER_MARGIN - margin)
		pointer_pos.y = clamp(pointer_pos.y, center.y - POINTER_MARGIN + margin, center.y + POINTER_MARGIN - margin)
		pointer.position = pointer_pos - pointer.pivot_offset
		pointer.rotation = dir.angle() + PI / 2
		pointer_attachment.rotation = - pointer.rotation


func _remove_pointer(pointer):
	if !is_instance_valid(pointer) || pointer is not Control:
		return

	for target in target_pointers:
		if target_pointers[target] == pointer:
			pointer.hide()
			pointer.queue_free()
			target_pointers.erase(target)
			break


func _validate_target_data(target_data: Dictionary) -> bool:
	if not target_data.has("node") or not is_instance_valid(target_data.node):
		return false
	if not target_data.has("image") or not (target_data.image is Texture):
		target_data.image = null
	
	return true
