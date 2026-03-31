class_name BallCupMinigame
extends Minigame

const SHUFFLE_SPEED := 0.5
const SHOW_DURATION := 0.6
const LIFT_HEIGHT := 30
const LIFT_SPEED := 0.3

@onready var correct_button: TextureButton = $CorrectButton
@onready var correct_cup: TextureRect = correct_button.get_node("Cup")
@onready var wrong_button_1: TextureButton = $WrongButton1
@onready var wrong_button_2: TextureButton = $WrongButton2


func start():
	correct_cup.position = Vector2.ZERO

	await super ()
	
	await lift_cup(true)

	# Shuffle cup positions
	var shuffle_count := randi_range(4, 6)
	for i in range(shuffle_count):
		var buttons := [correct_button, wrong_button_1, wrong_button_2]
		var btn_a = buttons.pick_random()
		buttons.erase(btn_a)
		var btn_b = buttons.pick_random()

		var tween := create_tween()
		tween.tween_property(btn_a, "position", btn_b.position, SHUFFLE_SPEED)
		tween.set_parallel()
		tween.tween_property(btn_b, "position", btn_a.position, SHUFFLE_SPEED)
		
		await tween.finished
	
	enable_input()


func lift_cup(also_drop: bool = false):
	var tween := create_tween()
	var cup_start_y := correct_cup.position.y
	tween.tween_property(correct_cup, "position:y", cup_start_y - LIFT_HEIGHT, LIFT_SPEED)

	if also_drop:
		tween.tween_property(correct_cup, "position:y", cup_start_y, LIFT_SPEED).set_delay(SHOW_DURATION)
	
	await tween.finished


func _handle_option_select(correct: bool):
	if !_input_enabled:
		return

	enable_input(false)

	await lift_cup()

	if !correct:
		modulate = Color(1, 0, 0, 1)

	await get_tree().create_timer(SHOW_DURATION).timeout

	if correct:
		complete()
	else:
		fail("You lost the ball! Better luck next time!")


func _on_correct_button_pressed():
	_handle_option_select(true)


func _on_wrong_button_1_pressed():
	_handle_option_select(false)


func _on_wrong_button_2_pressed():
	_handle_option_select(false)
