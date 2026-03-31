class_name Stage
extends Node3D

@onready var spawn_point: Marker3D = $SpawnPoint
@onready var delivery_point_holder: Node3D = $DeliveryPoints
@onready var garage: Garage = $Garage

@export var time_limit: float = 999.0
@onready var timer := time_limit

@export var enabled_minigames: Array[Minigame.Type]
@export var terrain: Node3D

var delivery_points: Array[DeliveryPoint] = []
var curr_delivery_idx: int = 0

var active: bool = false


func _ready():
	for child in delivery_point_holder.get_children():
		if child is DeliveryPoint:
			delivery_points.append(child)
			child.delivered.connect(_on_delivery_point_delivered)
	
	activate_next_delivery_point()

	UILayer.hud.minigame_handler.set_enabled_types(enabled_minigames)
	UILayer.hud.minigame_handler.set_paused(false)


func _process(delta):
	if active:
		if timer > 0:
			timer -= delta
			UILayer.hud.stage_timer.display_time(timer)
		if timer <= 0:
			StageLoader.car.destroy()
			StageLoader.fail_stage("Time's up!")
			active = false


func activate_next_delivery_point():
	var next_point := delivery_points[curr_delivery_idx]
	next_point.set_active()
	UILayer.hud.screen_pointer.add_target(next_point)


func complete_delivery():
	var curr_point := delivery_points[curr_delivery_idx]
	UILayer.hud.screen_pointer.remove_target(curr_point)
	AudioManager.play_sound(preload("res://assets/sfx/orchestra_hit.mp3"), -8.0).set_pitch(1.0 + float(curr_delivery_idx) * 0.1)

	if curr_delivery_idx + 1 >= delivery_points.size():
		garage.set_active()
		UILayer.hud.screen_pointer.add_target(garage.area)
		return
	
	curr_delivery_idx += 1
	activate_next_delivery_point()


func get_spawn_transform() -> Transform3D:
	if spawn_point:
		return spawn_point.global_transform
	
	return Transform3D.IDENTITY


func _on_delivery_point_delivered():
	complete_delivery()
