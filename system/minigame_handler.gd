class_name MinigameHandler
extends Node

enum MinigameType {
	SIMON_SAYS,
	THERMOMETER,
	BALL_CUP,
}
@export var enabled_types: Array[MinigameType] = []
@export_range(1.0, 10.0) var difficulty_mod := 1.0

const BASE_TRIGGER_INTERVAL := 2.0
@onready var trigger_timer := _get_trigger_interval()


func _process(delta):
	if trigger_timer > 0:
		trigger_timer -= delta
	else:
		trigger_random_minigame()


func trigger_random_minigame():
	if enabled_types.is_empty():
		return
	
	# Loop through enabled minigames randomly until we find one that isn't active
	var shuffled_types = enabled_types.duplicate()
	shuffled_types.shuffle()
	for minigame_type in shuffled_types:
		var minigame_node = _get_minigame_node(minigame_type)
		if !minigame_node || minigame_node.is_visible_in_tree() || minigame_node.is_on_cooldown():
			continue
		
		print("Triggering minigame: ", minigame_type)
		minigame_node.start()
		break

	trigger_timer = _get_trigger_interval()


func _get_minigame_node(minigame_type: MinigameType) -> Minigame:
	match minigame_type:
		MinigameType.SIMON_SAYS:
			return UILayer.hud.simon_says_minigame
		MinigameType.THERMOMETER:
			return UILayer.hud.thermometer_minigame
		MinigameType.BALL_CUP:
			return UILayer.hud.ball_cup_minigame
		_:
			return null


func _get_trigger_interval() -> float:
	return BASE_TRIGGER_INTERVAL / difficulty_mod
