extends CanvasLayer


func _on_handling_up_pressed():
	CarStats.add_handle(0.2)


func _on_acceleration_up_pressed():
	CarStats.add_accel(0.5)


func _on_speed_up_pressed():
	CarStats.add_speed(0.5)


func _on_exit_pressed():
	StageLoader.advance_stage()
