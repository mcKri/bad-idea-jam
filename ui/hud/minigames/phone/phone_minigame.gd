class_name PhoneMinigame
extends Minigame

@export_dir var prompt_dir: String

const SCROLL_WAIT_TIME := 0.5
const SCROLL_SPEED := 75.0

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var label: RichTextLabel = $ScrollContainer/RichTextLabel
@onready var phone_top: TextureRect = $PhoneTop

var _prompt_pool: Array[PhonePrompt]
var _curr_prompt: PhonePrompt
var _phone_shaker: Shaker
var _shaking := false
var _scroll_tween: Tween


func _ready():
	super ()

	# Load all resources in prompt dir with class PhonePrompt
	_prompt_pool = []
	for file_name in DirAccess.get_files_at(prompt_dir):
		var actual_name := file_name.trim_suffix(".remap")
		if !actual_name.ends_with(".tres"):
			continue
		
		var res := ResourceLoader.load(prompt_dir + "/" + actual_name)
		if res is PhonePrompt:
			if !res.enabled:
				continue
			_prompt_pool.append(res)
	
	_phone_shaker = Shaker.new(INF, 4.0, 0.02)
	phone_top.add_child(_phone_shaker)
	_phone_shaker.stop()


func start():
	super ()

	_curr_prompt = _prompt_pool.pick_random()
	_start_shaking()
	enable_input()
	display_text(_curr_prompt.message)


func display_text(text: String):
	_reset_scroll()
	label.text = text
	await get_tree().process_frame

	var text_width := label.get_content_width()
	var scroll_width := scroll_container.size.x
	if text_width <= scroll_width:
		return

	_idle_timer += SCROLL_WAIT_TIME
	await get_tree().create_timer(SCROLL_WAIT_TIME).timeout
	
	var max_scroll := text_width - scroll_width
	var scroll_time := max_scroll / SCROLL_SPEED
	_idle_timer += scroll_time
	_scroll_tween = create_tween()
	_scroll_tween.tween_property(scroll_container, "scroll_horizontal", max_scroll, scroll_time)
	await _scroll_tween.finished

	_idle_timer += SCROLL_WAIT_TIME
	await get_tree().create_timer(SCROLL_WAIT_TIME).timeout


func _reset_scroll():
	if _scroll_tween and _scroll_tween.is_valid():
		_scroll_tween.kill()
	scroll_container.scroll_horizontal = 0


func _start_shaking():
	if _shaking:
		return

	_shaking = true
	_shake()


func _shake():
	if !_shaking:
		return

	_phone_shaker.start()
	await get_tree().create_timer(1.0).timeout

	_phone_shaker.stop()
	await get_tree().create_timer(1.5).timeout

	_shake()


func _stop_shaking():
	_shaking = false
	_phone_shaker.stop()


func _finish():
	super ()

	label.text = ""
	_reset_scroll()


func _on_texture_button_pressed():
	if !_input_enabled:
		return
	
	_stop_shaking()
	enable_input(false)
	
	await display_text(_curr_prompt.message_2)
	if _curr_prompt.should_answer:
		complete()
	else:
		fail()


func handle_idle_timeout():
	if _curr_prompt.should_answer:
		fail()
	else:
		complete()
