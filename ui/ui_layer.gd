extends CanvasLayer

@onready var stage_fail_screen: CanvasLayer = $StageFailScreen


func _ready():
	stage_fail_screen.hide()
