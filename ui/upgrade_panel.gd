class_name UpgradePanel
extends CanvasLayer

@onready var time_left_label: RichTextLabel = %TimeLeftLabel


func set_time_left(time_left: float):
	var minutes = int(time_left) / 60.0
	var seconds = int(time_left) % 60
	var milliseconds = int(fmod(time_left * 1000, 1000.0))
	time_left_label.text = "%02d:%02d:%03d" % [minutes, seconds, milliseconds]


func _on_handling_up_pressed():
	CarStats.add_handle(0.2)


func _on_acceleration_up_pressed():
	CarStats.add_accel(0.5)


func _on_speed_up_pressed():
	CarStats.add_speed(0.5)


func _on_exit_pressed():
	StageLoader.advance_stage()
