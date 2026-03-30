class_name TransitionOverlay
extends MarginContainer

@onready var ap: AnimationPlayer = $AnimationPlayer

signal halfway
signal finished


func trigger():
	show()
	ap.play("transition")

	await ap.animation_finished
	hide()
	finished.emit()


func emit_halfway():
	halfway.emit()
