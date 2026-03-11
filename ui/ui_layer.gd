extends CanvasLayer

@onready var hud: HUD = $HUD
@onready var stage_fail_screen: CanvasLayer = $StageFailScreen
@onready var stage_complete_screen: CanvasLayer = $StageCompleteScreen


func _ready():
	stage_fail_screen.hide()
	stage_complete_screen.hide()
