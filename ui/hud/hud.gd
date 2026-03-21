class_name HUD
extends CanvasLayer

@onready var stage_timer: StageTimer = %StageTimer
@onready var screen_pointer: ScreenPointer = $ScreenPointer

# Minigames
@onready var simon_says_minigame: SimonSaysMinigame = %SimonSaysMinigame
