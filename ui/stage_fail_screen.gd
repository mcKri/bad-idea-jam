extends CanvasLayer


func _on_try_again_button_pressed():
	hide()
	StageLoader.restart_stage()
