class_name Minigame
extends Control

const BASE_COOLDOWN := 5.0

var _flash_tween: Tween
var _cooldown := 0.0


func _ready():
	hide()


func _process(delta):
	if _cooldown > 0.0:
		_cooldown -= delta


func modify_difficulty(mod: float):
	# Override in subclasses if needed
	pass


func start():
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


func stop_flashing():
	if _flash_tween:
		_flash_tween.kill()
	
	modulate = Color(1, 1, 1, 1)


func fail():
	_finish()
	StageLoader.car.box_anchor.launch_box(Vector3(0, 0, -10))


func complete():
	_finish()


func _finish():
	hide()
	_cooldown = BASE_COOLDOWN


func is_on_cooldown() -> bool:
	return _cooldown > 0.0
