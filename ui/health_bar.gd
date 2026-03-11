class_name HealthBar
extends ProgressBar

const DISPLAY_DURATION := 2.0

@export var screen_offset_y: float = 100.0

@onready var parent: Node3D = get_parent() as Node3D

var display_timer := 0.0


func _ready():
	hide()
	call_deferred("reparent", UILayer)


func _process(_delta):
	if !is_instance_valid(parent):
		hide()
		queue_free()
		return
	
	if display_timer > 0.0:
		display_timer -= _delta
	if display_timer <= 0.0:
		hide()
	
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	
	var parent_screen_pos := camera.unproject_position(parent.global_position)
	var target_screen_pos := parent_screen_pos + Vector2(0.0, -screen_offset_y)
	global_position = target_screen_pos - size * 0.5


func set_maximum(max_health: float):
	max_value = max_health
	value = max_health


func update(health: float):
	value = health
	display_timer = DISPLAY_DURATION
	show()
