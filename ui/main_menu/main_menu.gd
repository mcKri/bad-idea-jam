class_name MainMenu
extends Control

@onready var continue_button: Button = %ContinueButton
@onready var menu_body: Control = $MainMenu
@onready var settings_menu: Control = $SettingsMenu
@onready var transition: Control = $Transition
@onready var transition_ap: AnimationPlayer = $Transition/AnimationPlayer


func _ready():
	continue_button.disabled = !SaveSystem.has_save_data()
	menu_body.show()
	settings_menu.hide()


func _on_new_game_button_pressed():
	StageLoader.load_stage(0, 0)
	await play_transition()

	hide()


func _on_continue_button_pressed():
	SaveSystem.load_game()
	var world_idx: int = SaveSystem.get_property("world")
	var stage_idx: int = SaveSystem.get_property("stage")
	print("Loaded save data: world=" + str(world_idx) + ", stage=" + str(stage_idx))
	
	StageLoader.load_stage(stage_idx, world_idx)
	await play_transition()
	
	hide()


func _on_settings_button_pressed():
	menu_body.hide()
	settings_menu.show()


func _on_exit_button_pressed():
	get_tree().quit()


func _on_back_button_pressed():
	settings_menu.hide()
	menu_body.show()


func play_transition():
	StageLoader.stage.active = false
	transition.show()
	transition_ap.play("transition")
	await transition_ap.animation_finished

	transition.hide()
	StageLoader.stage.active = true
