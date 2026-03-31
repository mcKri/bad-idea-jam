class_name BoxAnchor
extends Marker3D

const STACK_RANDOM_OFFSET := 0.15

const IMPACT_COOLDOWN_LENGTH := 0.5
const MIN_LAUNCH_FORCE := 4.0
const MAX_LAUNCH_FORCE := 12.0

var boxes: Array[Box]
var impact_cooldown := 0.0


func _physics_process(delta):
	if impact_cooldown > 0:
		impact_cooldown -= delta


func add_box(box: Box):
	var anchor: Marker3D
	if boxes.size() > 0:
		anchor = boxes.back().stack_anchor
	else:
		anchor = self
	
	if box.is_inside_tree():
		box.reparent(anchor)
	else:
		anchor.add_child(box)
	
	box.freeze = true
	box.enable_interaction(false)
	
	var offset = Vector3(randf_range(-STACK_RANDOM_OFFSET, STACK_RANDOM_OFFSET), 0, randf_range(-STACK_RANDOM_OFFSET, STACK_RANDOM_OFFSET))
	box.position = offset
	box.rotation = Vector3.ZERO
	
	boxes.append(box)


func impact_box(force: Vector3):
	if !boxes:
		return

	if impact_cooldown > 0:
		return
	
	impact_cooldown = IMPACT_COOLDOWN_LENGTH
	
	# var launch_chance := (force.length() - MIN_LAUNCH_FORCE) / (MAX_LAUNCH_FORCE - MIN_LAUNCH_FORCE)
	# print("Impact force: ", force.length(), " Launch chance: ", launch_chance)
	# if randf() < launch_chance:
	# 	launch_box(force)
	# 	return
	
	for box in boxes:
		var shaker := Shaker.new(0.04 * force.length(), 0.05 * force.length())
		box.add_child(shaker)


func launch_box(force: Vector3):
	if !boxes:
		return

	var box = boxes.pop_back()
	box.drop()
	box.apply_central_impulse(force)
	

func deliver_box(box: Box) -> bool:
	var idx := boxes.find(box)
	if idx == -1:
		return false
	
	elif idx < boxes.size() - 1:
		var above_box := boxes[idx + 1]
		var new_parent: Node3D
		if idx == 0:
			new_parent = self
		else:
			new_parent = boxes[idx - 1].stack_anchor
		
		above_box.reparent(new_parent, false)

	boxes.erase(box)
	box.queue_free()

	return true


func reset():
	for box in boxes:
		box.queue_free()
	boxes.clear()
