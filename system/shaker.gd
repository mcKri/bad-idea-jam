class_name Shaker
extends Node

var _duration: float
var _amp: float
var _freq: float
var _timer: Timer
var _subscribers: Array[Node]

var _x_enabled := true
var _y_enabled := true
var _z_enabled := true

var is_shaking := false


func _init(duration: float, amp: float = 0.2, freq: float = 0.02):
	_duration = duration
	_amp = amp
	_freq = freq
	_timer = Timer.new()
	add_child(_timer)


func _ready():
	add_subscriber(get_parent())
	start()


func enable_axes(x: bool, y: bool, z: bool):
	_x_enabled = x
	_y_enabled = y
	_z_enabled = z


func add_subscriber(subscriber: Variant):
	if "position" in subscriber:
		_subscribers.append(subscriber)


func _shake():
	if not is_shaking:
		return

	if _duration <= 0:
		queue_free()
		return

	_amp *= 1 - _freq / _duration

	if _duration > _freq:
		_timer.wait_time = _freq
		_duration -= _freq
	else:
		_timer.wait_time = _duration
		_duration = 0
	

	var dir := Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
	if not _x_enabled:
		dir.x = 0
	if not _y_enabled:
		dir.y = 0
	if not _z_enabled:
		dir.z = 0
	
	for target in _subscribers:
		if target is Node3D:
			target.translate(dir * _amp)
		elif target is Node2D:
			target.translate(Vector2(dir.x, dir.y) * _amp)
		elif target is Control:
			target.position += Vector2(dir.x, dir.y) * _amp
	
	_timer.start()
	await _timer.timeout

	for target in _subscribers:
		if target is Node3D:
			target.translate(-dir * _amp)
		elif target is Node2D:
			target.translate(Vector2(-dir.x, dir.y) * _amp)
		elif target is Control:
			target.position -= Vector2(dir.x, dir.y) * _amp
	
	_shake()


func start():
	is_shaking = true
	_shake()


func stop():
	is_shaking = false
