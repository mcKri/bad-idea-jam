class_name MainMenu
extends CenterContainer

@onready var continue_button: Button = %ContinueButton
@onready var body: Control = $MarginContainer/VBoxContainer
@onready var settings_menu: Control = $MarginContainer/SettingsMenu


func _ready():
	continue_button.visible = SaveSystem.has_save_data()
	body.show()
	settings_menu.hide()


func _on_new_game_button_pressed():
	StageLoader.load_stage(0, 0)
	hide()


func _on_continue_button_pressed():
	await SaveSystem.load_game()

	var world_idx: int = SaveSystem.get_property("world")
	var stage_idx: int = SaveSystem.get_property("stage")
	print("Loaded save data: world=" + str(world_idx) + ", stage=" + str(stage_idx))
	StageLoader.load_stage(stage_idx, world_idx)
	hide()


func _on_settings_button_pressed():
	body.hide()
	settings_menu.show()


func _on_exit_button_pressed():
	get_tree().quit()


func _on_back_button_pressed():
	settings_menu.hide()
	body.show()
