extends CanvasLayer


func _on_next_stage_button_pressed():
	hide()
	StageLoader.advance_stage()
