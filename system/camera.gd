extends Camera3D

const DEFAULT_OFFSET := Vector3(0, 15, -2)

var focus_target: Node3D
var focus_point: Vector3 = Vector3.INF
var focus_speed: float = 0.15
var panning: bool = false
var anchor_offset: Vector3 = DEFAULT_OFFSET


func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready():
	make_current()


func _process(_delta):
	var target_pos := Vector3.INF
	
	# Priority: target node > focus point > current position
	if focus_target:
		target_pos = focus_target.global_position
	elif focus_point != Vector3.INF:
		target_pos = focus_point
	
	var anchor_pos := target_pos + anchor_offset
	
	# Smoothly pan to target if currently panning, otherwise snap immediately
	if panning:
		if global_position.distance_to(anchor_pos) > 0.01:
			global_position = lerp(global_position, anchor_pos, focus_speed)
		else:
			global_position = anchor_pos
			panning = false
	else:
		if anchor_pos != Vector3.INF:
			global_position = anchor_pos
	
	look_at(target_pos, Vector3.UP)


func focus_on(target: Variant, speed: float = 0.15):
	if target is Node3D:
		focus_target = target
	elif target is Vector3:
		focus_point = target
		focus_target = null
	else:
		return

	if speed == INF:
		global_position = focus_point if focus_point != Vector3.INF else focus_target.global_position
	else:
		focus_speed = speed
		panning = true


func clear_focus():
	focus_target = null
	focus_point = Vector3.INF


func set_offset(new_offset: Vector3):
	anchor_offset = new_offset


func reset_offset():
	anchor_offset = DEFAULT_OFFSET
