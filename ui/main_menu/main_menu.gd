class_name MainMenu
extends Control

@onready var continue_button: Button = %ContinueButton
@onready var menu_body: Control = $MainMenu
@onready var settings_menu: Control = $SettingsMenu
@onready var controls_screen: Control = $ControlsScreen
@onready var credits_screen: Control = $CreditsScreen
@onready var link_copied_label: RichTextLabel = $CreditsScreen/MarginContainer/VBoxContainer/LinkCopiedLabel


func _ready():
	hide()
	continue_button.disabled = !SaveSystem.has_save_data()


func _input(event: InputEvent):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if settings_menu.visible:
				settings_menu.hide()
				menu_body.show()
			elif controls_screen.visible:
				controls_screen.hide()
				menu_body.show()
			elif credits_screen.visible:
				credits_screen.hide()
				menu_body.show()


func open():
	AudioManager.play_music(preload("res://assets/music/gj_1.2.mp3"))
	menu_body.show()
	settings_menu.hide()
	controls_screen.hide()
	credits_screen.hide()
	show()


func _on_new_game_button_pressed():
	StageLoader.load_stage(0, 0)
	await transition_to_stage()

	hide()


func _on_continue_button_pressed():
	SaveSystem.load_game()
	var world_idx: int = SaveSystem.get_property("world")
	var stage_idx: int = SaveSystem.get_property("stage")
	print("Loaded save data: world=" + str(world_idx) + ", stage=" + str(stage_idx))
	
	StageLoader.load_stage(stage_idx, world_idx)
	await transition_to_stage()
	
	hide()


func _on_settings_button_pressed():
	menu_body.hide()
	settings_menu.show()


func _on_exit_button_pressed():
	get_tree().quit()


func _on_back_button_pressed():
	settings_menu.hide()
	menu_body.show()


func transition_to_stage():
	StageLoader.stage.active = false
	UILayer.transition_overlay.trigger()
	await UILayer.transition_overlay.halfway
	
	hide()
	StageLoader.stage.show()
	await UILayer.transition_overlay.finished

	StageLoader.stage.active = true


func _on_controls_screen_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		controls_screen.hide()
		menu_body.show()


func _on_controls_button_pressed():
	menu_body.hide()
	controls_screen.show()


func _on_credits_button_pressed():
	menu_body.hide()
	link_copied_label.hide()
	credits_screen.show()


func _on_credits_back_button_pressed():
	credits_screen.hide()
	menu_body.show()


func _on_link_meta_clicked(meta):
	# Copy to clipboard
	DisplayServer.clipboard_set(meta)
	link_copied_label.show()
