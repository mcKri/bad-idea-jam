class_name ThermometerMinigame
extends Minigame

@export var textures: Array[Texture2D]

@onready var button: TextureButton = $TextureButton

const MAX_TEMP := 100.0
const MIN_TEMP := 0.0
const FAIL_MARGIN := 10.0

var temp := 50.0:
	set(val):
		temp = val
		_update_texture()
var cooling := false


func start():
	super ()
	temp = 50.0
	cooling = false


func _process(delta):
	if !is_visible_in_tree():
		return

	if cooling:
		temp -= delta * 20.0
	else:
		temp += delta * 10.0
	
	if temp >= MAX_TEMP + FAIL_MARGIN || temp <= MIN_TEMP - FAIL_MARGIN:
		fail()


func _toggle_cooling():
	cooling = !cooling


func _update_texture():
	var t = clamp((temp - MIN_TEMP) / (MAX_TEMP - MIN_TEMP), 0.0, 1.0)
	var idx = int(t * (textures.size() - 1))
	button.texture_normal = textures[idx]


func _on_texture_button_pressed():
	_toggle_cooling()
