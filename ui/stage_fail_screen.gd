class_name StageFailScreen
extends CanvasLayer

@onready var reason_label: RichTextLabel = %ReasonLabel


func open(reason: String = ""):
	reason_label.text = reason
	show()


func _on_try_again_button_pressed():
	hide()
	StageLoader.restart_stage()
