class_name ThermometerMinigame
extends Minigame

@export var textures: Array[Texture2D]

@onready var thermometer: TextureButton = $TextureButton
@onready var switch: TextureButton = $TextureButton2

const COLD_SWITCH_TEXTURE := preload("res://ui/hud/minigames/thermometer/cold.png")
const HOT_SWITCH_TEXTURE := preload("res://ui/hud/minigames/thermometer/hot.png")

const MAX_TEMP := 100.0
const MIN_TEMP := 0.0
const FAIL_MARGIN := 10.0
const TEMP_DELTA := 15.0

var temp := 50.0:
	set(val):
		temp = val
		_update_texture()
var cooling := false:
	set(val):
		cooling = val
		switch.texture_normal = COLD_SWITCH_TEXTURE if cooling else HOT_SWITCH_TEXTURE


func _ready():
	super ()

	enable_idle_tracking(false)
	enable_input()


func start():
	temp = 50.0
	cooling = false
	
	await super ()


func _process(delta):
	super (delta)

	if !is_visible_in_tree():
		return

	if cooling:
		temp -= delta * TEMP_DELTA
	else:
		temp += delta * TEMP_DELTA * 0.5
	
	# Flashing
	if temp >= MAX_TEMP - FAIL_MARGIN && !cooling:
		start_flashing()
	elif temp <= MIN_TEMP + FAIL_MARGIN && cooling:
		start_flashing()
	else:
		stop_flashing()

	# Failure check
	if temp >= MAX_TEMP + FAIL_MARGIN:
		fail("You overheated! Keep an eye on the thermometer next time!")
	elif temp <= MIN_TEMP - FAIL_MARGIN:
		fail("You froze! Keep an eye on the thermometer next time!")


func _toggle_cooling():
	cooling = !cooling


func _update_texture():
	var t = clamp((temp - MIN_TEMP) / (MAX_TEMP - MIN_TEMP), 0.0, 1.0)
	var idx = int(t * (textures.size() - 1))
	thermometer.texture_normal = textures[idx]


func _on_texture_button_pressed():
	_toggle_cooling()


func _on_texture_button_2_pressed():
	_toggle_cooling()
