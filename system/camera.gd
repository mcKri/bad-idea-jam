extends Camera3D

const DEFAULT_OFFSET := Vector3(0, 18, 1)
const DEFAULT_PAN_SPEED := 20.0

var look_target: Node3D
var look_point: Vector3 = Vector3.INF
var anchor_offset: Vector3 = DEFAULT_OFFSET

var pan_speed: float = DEFAULT_PAN_SPEED
var panning: bool = false

var _fixed_basis: Basis
var _pan_origin: Vector3
var _pan_duration: float
var _pan_t: float = 1.0
var _bounds: AABB


func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready():
	_update_basis()
	make_current()


func _process(delta):
	var target_pos := Vector3.INF
	
	# Priority: target node > focus point > current position
	if look_target:
		target_pos = look_target.global_position
	elif look_point != Vector3.INF:
		target_pos = look_point
	
	# Clamp target position within bounds if set
	if target_pos != Vector3.INF and _bounds.size != Vector3.ZERO:
		target_pos = target_pos.clamp(_bounds.position, _bounds.end)
	
	var anchor_pos := target_pos + anchor_offset
	
	# Smoothly pan to target if currently panning, otherwise snap immediately
	if panning:
		_pan_t = minf(_pan_t + delta / _pan_duration, 1.0)
		var eased := smoothstep(0.0, 1.0, _pan_t)
		global_position = _pan_origin.lerp(anchor_pos, eased)
		if _pan_t >= 1.0:
			global_position = anchor_pos
			panning = false
	else:
		if anchor_pos != Vector3.INF:
			global_position = anchor_pos
	
	basis = _fixed_basis


func _update_basis():
	_fixed_basis = Basis.looking_at(-anchor_offset.normalized(), Vector3.UP)


func set_target(target: Variant, speed: float = DEFAULT_PAN_SPEED):
	if target is Node3D:
		look_target = target
	elif target is Vector3:
		look_point = target
		look_target = null
	else:
		return

	if speed == INF:
		global_position = look_point if look_point != Vector3.INF else look_target.global_position
		panning = false
	else:
		pan_speed = speed
		var dest := look_target.global_position if look_target else look_point
		_pan_origin = global_position
		_pan_duration = maxf(global_position.distance_to(dest + anchor_offset) / pan_speed, 0.001)
		_pan_t = 0.0
		panning = true


func clear_target():
	look_target = null
	look_point = Vector3.INF


func set_offset(new_offset: Vector3):
	anchor_offset = new_offset
	_update_basis()


func reset_offset():
	anchor_offset = DEFAULT_OFFSET
	_update_basis()


func set_bounds(bounds: AABB):
	_bounds = bounds
