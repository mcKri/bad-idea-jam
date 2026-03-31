class_name Minigame
extends Control

enum Type {
	THERMOMETER,
	SIMON_SAYS,
	BALL_CUP,
	YES_NO,
	PHONE,
}

const BASE_COOLDOWN := 5.0
const FADE_IN_TIME := 1.0
const IDLE_TIME := 5.0
const IDLE_FLASH_TIME := 2.0
const EXPLOSION_SCENE := preload("res://entities/explosion/explosion.tscn")
const FAILURE_DAMAGE := 120.0

const SILHOUETTE_SHADER: Shader = preload("res://assets/shader/silhouette.tres")
var _silhouette_material: ShaderMaterial

const WARNING_SOUND: AudioStream = preload("res://assets/sfx/minigame_almost_fail_2.ogg")
var _warning_sound: AudioInstance
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
	_initialize_silhouette()
	_shaker = Shaker.new(INF, 3.0, 0.02)
	add_child(_shaker)
	_shaker.stop()
	hide()


func _initialize_silhouette():
	_silhouette_material = ShaderMaterial.new()
	_silhouette_material.shader = SILHOUETTE_SHADER

	var children := _get_all_children(self )
	for child in children:
		if child is CanvasItem:
			child.material = _silhouette_material
		

func _get_all_children(node: Node) -> Array:
	var result := []
	for child in node.get_children():
		result.append(child)
		result += _get_all_children(child)
	
	return result


func _process(delta):
	if _cooldown > 0.0:
		_cooldown -= delta
	
	if is_visible_in_tree() && _input_enabled && _idle_tracking_enabled:
		if _idle_timer > 0:
			_idle_timer -= delta
			if _idle_timer <= 0.0:
				handle_idle_timeout()
			elif _idle_timer <= IDLE_FLASH_TIME:
				start_flashing()


func modify_difficulty(mod: float):
	# Override in subclasses if needed
	pass


func start():
	enable_input(false)
	stop_flashing()
	AudioManager.play_sound(preload("res://assets/sfx/minigame_appear.mp3"))
	_silhouette_material.set_shader_parameter("color", Color.WHITE)
	show()
	var tween = create_tween()
	tween.tween_property(_silhouette_material, "shader_parameter/color", Color.BLACK, FADE_IN_TIME)
	
	await tween.finished


func start_flashing():
	if _flash_tween and _flash_tween.is_valid():
		return

	_flash_tween = create_tween()
	_flash_tween.set_loops()
	_flash_tween.set_trans(Tween.TRANS_SINE)
	_flash_tween.tween_property(self , "modulate", Color(1, 0, 0, 1), 0.5)
	_flash_tween.tween_property(self , "modulate", Color(1, 1, 1, 1), 0.5)
	_warning_sound = AudioManager.play_sound(WARNING_SOUND).loop()
	_shaker.start()


func stop_flashing():
	if _flash_tween:
		_flash_tween.kill()
	
	if _warning_sound:
		_warning_sound.stop()
	
	_shaker.stop()
	modulate = Color(1, 1, 1, 1)


func fail(message: String = "You failed the minigame!"):
	# AudioManager.play_sound(preload("res://assets/sfx/minigame_fail.ogg"))
	_finish()
	if !StageLoader.car.god_mode:
		StageLoader.fail_stage(message)

	# if is_instance_valid(StageLoader.car):
	# 	var explosion: Explosion = EXPLOSION_SCENE.instantiate()
	# 	explosion.start(StageLoader.car)

	# 	if StageLoader.car.box_anchor.boxes.size() > 0:
	# 		if not StageLoader.car.god_mode:
	# 			StageLoader.car.box_anchor.launch_box(Vector3(0, 0, -10))
	# 	else:
	# 		StageLoader.car.damage(FAILURE_DAMAGE)	


func complete():
	AudioManager.play_sound(preload("res://assets/sfx/minigame_pass.ogg"))
	_finish()


func _finish(with_cooldown: bool = true):
	hide()
	_cooldown = BASE_COOLDOWN if with_cooldown else 0.0
	_input_enabled = false


func is_on_cooldown() -> bool:
	print("Minigame: Checking cooldown: ", _cooldown)
	return _cooldown > 0.0


func enable_input(enable: bool = true):
	_input_enabled = enable


func enable_idle_tracking(enable: bool = true):
	_idle_tracking_enabled = enable


func reset_idle_timer():
	stop_flashing()
	_idle_timer = IDLE_TIME


func handle_idle_timeout():
	fail()
