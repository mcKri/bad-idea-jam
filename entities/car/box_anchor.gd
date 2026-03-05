class_name BoxAnchor
extends Marker3D

const STACK_RANDOM_OFFSET := 0.15

const IMPACT_COOLDOWN_LENGTH := 0.5
const MIN_LAUNCH_FORCE := 4.0
const MAX_LAUNCH_FORCE := 12.0

var boxes: Array[RigidBody3D]
var impact_cooldown := 0.0


func _physics_process(delta):
	if impact_cooldown > 0:
		impact_cooldown -= delta


func add_box(box: RigidBody3D):
	add_child(box)
	box.freeze = true
	
	var offset = Vector3(randf_range(-STACK_RANDOM_OFFSET, STACK_RANDOM_OFFSET), 0, randf_range(-STACK_RANDOM_OFFSET, STACK_RANDOM_OFFSET))
	if boxes.size() > 0:
		var last_box = boxes.back()
		box.global_position = last_box.stack_anchor.global_position + offset
	else:
		box.global_position = global_position + offset
	
	boxes.append(box)


func impact_box(force: Vector3):
	if !boxes:
		return

	if impact_cooldown > 0:
		return
	
	impact_cooldown = IMPACT_COOLDOWN_LENGTH
	
	var launch_chance := (force.length() - MIN_LAUNCH_FORCE) / (MAX_LAUNCH_FORCE - MIN_LAUNCH_FORCE)
	print("Impact force: ", force.length(), " Launch chance: ", launch_chance)
	if randf() < launch_chance:
		launch_box(force)
		return
	
	for box in boxes:
		var shaker := Shaker.new(0.04 * force.length(), 0.05 * force.length())
		box.add_child(shaker)


func launch_box(force: Vector3):
	if !boxes:
		return

	var box = boxes.pop_back()
	box.reparent(StageLoader.curr_stage)
	box.freeze = false
	box.apply_central_impulse(force)


func reset():
	for box in boxes:
		box.queue_free()
	boxes.clear()
