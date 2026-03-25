extends Node

const SAVE_FILE_PATH := "user://save_data.json"

var _save_data: Dictionary = {
	"world": 0,
	"stage": 0,
}
var _subscriber_wait_list: Array[Callable]
var _saving: bool = false

signal save_started
signal _save_completed


func _input(event):
	if event.is_action_pressed("save_game"):
		print("Save game triggered")
		save_game()
	elif event.is_action_pressed("load_game"):
		load_game()


func save_game():
	_subscriber_wait_list = []
	for conn in save_started.get_connections():
		_subscriber_wait_list.append(conn.callable)
	
	_saving = true
	save_started.emit.call_deferred()

	await _save_completed
	_saving = false
	print("Save completed: " + str(_save_data))
	

func set_property(key: String, value: Variant):
	if not _saving:
		push_error("Attempted to set save property while not _saving")
		return

	if not _save_data.has(key):
		push_error("Invalid save key: " + key)
		return

	_save_data[key] = value
	

func resolve_save_connection(src_callable: Callable):
	if not _saving:
		push_error("Attempted to resolve save connection while not _saving")
		return

	if _subscriber_wait_list.has(src_callable):
		_subscriber_wait_list.erase(src_callable)
		if _subscriber_wait_list.is_empty():
			_write_save_file()
		else:
			print("Waiting for subscribers: " + str(_subscriber_wait_list))


func _write_save_file():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if !file:
		push_error("Failed to open save file for writing")
		return

	file.store_var(_save_data.duplicate())
	file.close()
	_save_completed.emit()


func load_game():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if !file:
		print("No save file found")
		return

	_save_data = file.get_var()
	file.close()


func get_property(key: String) -> Variant:
	if not _save_data.has(key):
		push_error("Invalid save key: " + key)
		return null

	return _save_data[key]


func has_save_data() -> bool:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if !file:
		return false

	file.close()
	return true
