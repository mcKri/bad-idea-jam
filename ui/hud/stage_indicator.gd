class_name StageIndicator
extends Control

const DISPLAY_TIME := 2.0
const FADE_TIME := 1.0

@onready var world_counter: Label = $MarginContainer/GridContainer/WorldCounter
@onready var stage_counter: Label = $MarginContainer/GridContainer/StageCounter

var _tween: Tween


func _ready():
	hide()


func display(world_idx: int, world_count: int, stage_idx: int, stage_count: int):
	if _tween and _tween.is_valid():
		_tween.kill()
	
	world_counter.text = str(world_idx + 1) + " / " + str(world_count)
	stage_counter.text = str(stage_idx + 1) + " / " + str(stage_count)
	modulate.a = 1.0
	show()

	await get_tree().create_timer(DISPLAY_TIME).timeout

	_tween = create_tween()
	_tween.tween_property(self , "modulate:a", 0.0, FADE_TIME)
	await _tween.finished
	
	hide()
