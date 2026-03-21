class_name Minigame
extends Control

enum Type {
	SIMON_SAYS,
	THERMOMETER,
	BALL_CUP,
}

const BASE_COOLDOWN := 5.0
const IDLE_TIME := 5.0
const IDLE_FLASH_TIME := 2.0

var _flash_tween: Tween
var _shaker: Shaker
var _cooldown := 0.0
var _idle_timer := IDLE_TIME
var _idle_tracking_enabled := true
var _input_enabled: bool = false:
	set(val):
		_input_enabled = val
		reset_idle_timer()


func _ready():
	_shaker = Shaker.new(INF, 3.0, 0.02)
	add_child(_shaker)
	_shaker.stop()
	hide()


func _process(delta):
	if _cooldown > 0.0:
		_cooldown -= delta
	
	if is_visible_in_tree() && _input_enabled && _idle_tracking_enabled:
		if _idle_timer > 0:
			_idle_timer -= delta
			if _idle_timer <= 0.0:
				fail()
			elif _idle_timer <= IDLE_FLASH_TIME:
				start_flashing()


func modify_difficulty(mod: float):
	# Override in subclasses if needed
	pass


func start():
	enable_input(false)
	stop_flashing()
	show()


func start_flashing():
	if _flash_tween and _flash_tween.is_valid():
		return

	_flash_tween = create_tween()
	_flash_tween.set_loops()
	_flash_tween.set_trans(Tween.TRANS_SINE)
	_flash_tween.tween_property(self , "modulate", Color(1, 0, 0, 1), 0.5)
	_flash_tween.tween_property(self , "modulate", Color(1, 1, 1, 1), 0.5)

	_shaker.start()


func stop_flashing():
	if _flash_tween:
		_flash_tween.kill()
	
	_shaker.stop()
	modulate = Color(1, 1, 1, 1)


func fail():
	_finish()
	StageLoader.car.box_anchor.launch_box(Vector3(0, 0, -10))


func complete():
	_finish()


func _finish():
	hide()
	_cooldown = BASE_COOLDOWN
	_input_enabled = false


func is_on_cooldown() -> bool:
	return _cooldown > 0.0


func enable_input(enable: bool = true):
	_input_enabled = enable


func enable_idle_tracking(enable: bool = true):
	_idle_tracking_enabled = enable


func reset_idle_timer():
	stop_flashing()
	_idle_timer = IDLE_TIME
