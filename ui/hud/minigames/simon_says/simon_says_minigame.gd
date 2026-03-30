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
const STEP_COUNT := 3
var playback_idx: int = 0

var input_step: int = 0


func start():
	texture_rect.texture = TEXTURES[ButtonColor.NONE]

	await super ()

	correct_sequence.clear()
	for i in range(STEP_COUNT):
		var random_color = ButtonColor.values()[randi_range(1, 4)]
		correct_sequence.append(random_color)
	
	print("Correct sequence: ", correct_sequence)

	await play_sequence()
	
	input_step = 0
	enable_input()


func _process(delta):
	super (delta)

	if !is_visible_in_tree() || !_input_enabled:
		return


func play_sequence():
	playback_idx = 0

	for color in correct_sequence:
		await get_tree().create_timer(PLAYBACK_INTERVAL * 0.5).timeout
		
		light_up_button(color)
		await get_tree().create_timer(PLAYBACK_INTERVAL).timeout

		light_up_button(ButtonColor.NONE)
		

func light_up_button(color: ButtonColor):
	texture_rect.texture = TEXTURES.get(color, TEXTURES[ButtonColor.NONE])
	# TODO: Play sound


func fail():
	modulate = Color(1, 0, 0, 1)
	await get_tree().create_timer(0.5).timeout

	super ()


func _on_red_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	_handle_button_input_event(ButtonColor.RED, event)


func _on_purple_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	_handle_button_input_event(ButtonColor.PURPLE, event)


func _on_green_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	_handle_button_input_event(ButtonColor.GREEN, event)


func _on_blue_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	_handle_button_input_event(ButtonColor.BLUE, event)


func _handle_button_input_event(button_color: ButtonColor, event: InputEvent):
	if not _input_enabled:
		return

	if event is InputEventMouseButton and event.pressed:
		light_up_button(button_color)
		reset_idle_timer()

		if button_color == correct_sequence[input_step]:
			input_step += 1

			if input_step >= correct_sequence.size():
				complete()
		else:
			# TODO: Play failure sound
			fail()
