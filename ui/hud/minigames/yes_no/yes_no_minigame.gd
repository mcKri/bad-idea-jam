class_name YesNoMinigame
extends Minigame


@export_dir var prompt_dir: String

const SCROLL_WAIT_TIME := 0.3
const SCROLL_SPEED := 150.0

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var label: RichTextLabel = $ScrollContainer/RichTextLabel
@onready var button_ap: AnimationPlayer = $ButtonAP
@onready var screen_ap: AnimationPlayer = $ScreenTexture/ScreenAP

var _prompt_pool: Array[YesNoPrompt]
var _curr_prompt: YesNoPrompt
var _scroll_tween: Tween


func _ready():
	super ()

	# Load all resources in prompt dir with class YesNoPrompt
	_prompt_pool = []
	for file_name in DirAccess.get_files_at(prompt_dir):
		var actual_name := file_name.trim_suffix(".remap")
		if !actual_name.ends_with(".tres"):
			continue
		
		var res := ResourceLoader.load(prompt_dir + "/" + actual_name)
		if res is YesNoPrompt:
			if !res.enabled:
				continue
			_prompt_pool.append(res)


func start():
	button_ap.play("RESET")

	await super ()
	
	_curr_prompt = _prompt_pool.pick_random()
	AudioManager.play_sound(_curr_prompt.audio, 3.0)
	await display_text(_curr_prompt.message, _curr_prompt.audio.get_length())
	
	button_ap.play("enter")
	await button_ap.animation_finished

	enable_input()


func display_text(text: String, audio_length: float = 0.0):
	_reset_scroll()
	label.text = text
	screen_ap.play("talk")
	await get_tree().process_frame

	var text_width := label.get_content_width()
	var scroll_width := scroll_container.size.x
	if text_width <= scroll_width:
		if audio_length > 0.0:
			_idle_timer += audio_length
			await get_tree().create_timer(audio_length).timeout
			
			screen_ap.stop()
		return

	_idle_timer += SCROLL_WAIT_TIME
	await get_tree().create_timer(SCROLL_WAIT_TIME).timeout

	var max_scroll := text_width - scroll_width
	var scroll_time: float
	if audio_length > 0.0:
		scroll_time = maxf(audio_length - SCROLL_WAIT_TIME * 2, 0.0)
	else:
		scroll_time = max_scroll / SCROLL_SPEED
	_idle_timer += scroll_time
	_scroll_tween = create_tween()
	_scroll_tween.tween_property(scroll_container, "scroll_horizontal", max_scroll, scroll_time)
	await _scroll_tween.finished

	_idle_timer += SCROLL_WAIT_TIME
	await get_tree().create_timer(SCROLL_WAIT_TIME).timeout

	screen_ap.stop()


func _reset_scroll():
	if _scroll_tween and _scroll_tween.is_valid():
		_scroll_tween.kill()
	scroll_container.scroll_horizontal = 0


func _answer(is_yes: bool):
	if is_yes == _curr_prompt.should_answer_yes:
		complete()
	else:
		fail("Wrong answer! Pay closer attention to the prompt next time!")


func _finish(with_cooldown: bool = true):
	super (with_cooldown)

	label.text = ""
	_reset_scroll()
	screen_ap.stop()


func _on_yes_button_pressed():
	if !_input_enabled:
		return
	
	_answer(true)


func _on_no_button_pressed():
	if !_input_enabled:
		return
	
	_answer(false)
