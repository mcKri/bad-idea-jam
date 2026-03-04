class_name BoxHolder
extends Area3D

var boxes: Array[RigidBody3D]


func add_box(box: RigidBody3D):
	add_child(box)
	box.global_position = global_position + Vector3(0, 0.0, 0)
	boxes.append(box)


func lose_box(box: RigidBody3D):
	if box not in boxes:
		return
	
	box.reparent(StageLoader.curr_stage)
	boxes.erase(box)


func reset():
	for box in boxes:
		box.queue_free()
	boxes.clear()


func _on_body_exited(body: Node3D):
	if body is not RigidBody3D || body not in boxes:
		return
	
	lose_box(body)
