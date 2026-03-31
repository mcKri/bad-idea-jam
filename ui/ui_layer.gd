extends CanvasLayer

@onready var splash_screen: SplashScreen = $SplashScreen
@onready var main_menu: MainMenu = $MainMenu
@onready var hud: HUD = $HUD
@onready var stage_fail_screen: CanvasLayer = $StageFailScreen
@onready var stage_complete_screen: CanvasLayer = $StageCompleteScreen
@onready var game_end_screen: GameEndScreen = $GameEndScreen
@onready var transition_overlay: TransitionOverlay = $TransitionOverlay


func _ready():
	hud.hide()
	stage_fail_screen.hide()
	stage_complete_screen.hide()
