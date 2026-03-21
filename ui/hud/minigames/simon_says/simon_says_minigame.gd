class_name SimonSaysMinigame
extends Minigame

enum ButtonColor {
	NONE,
	RED,
	PURPLE,
	GREEN,
	BLUE
}

const TEXTURES: Dictionary = {
	ButtonColor.NONE: preload("res://ui/hud/minigames/simon_says/ss_neutral.png"),
	ButtonColor.RED: preload("res://ui/hud/minigames/simon_says/ss_red.png"),
	ButtonColor.PURPLE: preload("res://ui/hud/minigames/simon_says/ss_purple.png"),
	ButtonColor.GREEN: preload("res://ui/hud/minigames/simon_says/ss_green.png"),
	ButtonColor.BLUE: preload("res://ui/hud/minigames/simon_says/ss_blue.png")
}

@onready var texture_rect: TextureRect = $TextureRect

var correct_sequence: Array[ButtonColor] = []
const PLAYBACK_INTERVAL := 1.0
var playback_idx: int = 0

var input_step: int = 0

var input_enabled: bool = false


func start():
	super ()

	correct_sequence.clear()
	var num_steps = randi_range(3, 6)
	for i in range(num_steps):
		var random_color = ButtonColor.values()[randi_range(1, 4)]
		correct_sequence.append(random_color)
	
	print("Correct sequence: ", correct_sequence)

	play_sequence()
	input_step = 0


func play_sequence():
	input_enabled = false
	playback_idx = 0


	for color in correct_sequence:
		await get_tree().create_timer(PLAYBACK_INTERVAL * 0.5).timeout
		
		light_up_button(color)
		await get_tree().create_timer(PLAYBACK_INTERVAL).timeout

		light_up_button(ButtonColor.NONE)
	
	input_enabled = true
		

func light_up_button(color: ButtonColor):
	texture_rect.texture = TEXTURES.get(color, TEXTURES[ButtonColor.NONE])
	# TODO: Play sound


func _on_red_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	_handle_button_input_event(ButtonColor.RED, event)


func _on_purple_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	_handle_button_input_event(ButtonColor.PURPLE, event)


func _on_green_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	_handle_button_input_event(ButtonColor.GREEN, event)


func _on_blue_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	_handle_button_input_event(ButtonColor.BLUE, event)


func _handle_button_input_event(button_color: ButtonColor, event: InputEvent):
	if not input_enabled:
		return

	if event is InputEventMouseButton and event.pressed:
		light_up_button(button_color)

		if button_color == correct_sequence[input_step]:
			input_step += 1

			if input_step >= correct_sequence.size():
				complete()
		else:
			# TODO: Play failure sound
			fail()
