class_name GameEndScreen
extends Control


func _ready():
	hide()


func _on_button_pressed():
	hide()
	UILayer.main_menu.show()
