class_name Minigame
extends Control


func _ready():
	hide()


func modify_difficulty(mod: float):
	# Override in subclasses if needed
	pass


func start():
	show()


func fail():
	_finish()
	StageLoader.car.box_anchor.launch_box(Vector3(0, 0, -100))


func complete():
	_finish()


func _finish():
	hide()
