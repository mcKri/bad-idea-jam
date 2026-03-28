class_name MinigameHandler
extends Control

@onready var simon_says_minigame: SimonSaysMinigame = %SimonSaysMinigame
@onready var thermometer_minigame: ThermometerMinigame = %ThermometerMinigame
@onready var ball_cup_minigame: BallCupMinigame = %BallCupMinigame
@onready var phone_minigame: PhoneMinigame = %PhoneMinigame

const BASE_TRIGGER_INTERVAL := 9.0
var trigger_timer := BASE_TRIGGER_INTERVAL * 0.5
var enabled_types: Array[Minigame.Type]


func _process(delta):
	if trigger_timer > 0:
		trigger_timer -= delta
	else:
		trigger_random_minigame()


func set_enabled_types(types: Array[Minigame.Type]):
	enabled_types = types.duplicate()


func set_paused(pause: bool = true):
	visible = !pause
	var new_process_mode := \
		ProcessMode.PROCESS_MODE_DISABLED if pause \
		else ProcessMode.PROCESS_MODE_INHERIT
	set_deferred("process_mode", new_process_mode)


func trigger_random_minigame():
	if enabled_types.is_empty():
		return
	
	# Loop through enabled minigames randomly until we find one that isn't active
	var shuffled_types = enabled_types.duplicate()
	shuffled_types.shuffle()
	for minigame_type in shuffled_types:
		var minigame_node = _get_minigame_node(minigame_type)
		if !minigame_node \
		|| minigame_node.is_visible_in_tree() \
		|| minigame_node.is_on_cooldown():
			continue
		
		print("Triggering minigame: ", minigame_type)
		minigame_node.start()
		break

	trigger_timer = BASE_TRIGGER_INTERVAL


func _get_minigame_node(minigame_type: Minigame.Type) -> Minigame:
	match minigame_type:
		Minigame.Type.SIMON_SAYS:
			return simon_says_minigame
		Minigame.Type.THERMOMETER:
			return thermometer_minigame
		Minigame.Type.BALL_CUP:
			return ball_cup_minigame
		Minigame.Type.PHONE:
			return phone_minigame
		_:
			return null


func reset():
	trigger_timer = BASE_TRIGGER_INTERVAL * 0.5
	simon_says_minigame._finish()
	thermometer_minigame._finish()
	ball_cup_minigame._finish()
	phone_minigame._finish()
