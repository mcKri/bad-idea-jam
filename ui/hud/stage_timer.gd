class_name StageTimer
extends Control

@onready var bar: TextureProgressBar = $TextureProgressBar
@onready var label: Label = $Label

var _max_time: float = 0.0


func set_max_time(seconds: float):
	_max_time = seconds
	display_time(seconds)


func display_time(seconds: float):
	seconds = clamp(seconds, 0.0, _max_time)
	var minutes := int(seconds / 60)
	var seconds_remainder := int(seconds) % 60

	var time_string := ""
	if minutes > 0:
		time_string = "%02d:%02d" % [minutes, seconds_remainder]
	else:
		time_string = "%02d" % seconds

	label.text = time_string
	bar.value = seconds / _max_time * 100.0
