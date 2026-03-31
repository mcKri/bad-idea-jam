class_name SplashScreen
extends MarginContainer

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var overlay: ColorRect = $Overlay


func play():
	overlay.show()
	ap.play("fade_in_out")
	await ap.animation_finished

	hide()
	UILayer.main_menu.open()
