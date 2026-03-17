class_name Garage
extends Node3D

@onready var area: Area3D = $Area3D
@onready var sprite: Sprite3D = $Area3D/CollisionShape3D/Sprite3D


func _ready():
	set_active(false)


func set_active(active: bool = true):
	area.visible = active
	area.monitoring = active


func _on_speed_up_pressed() -> void:
	CarStats.add_speed(0.5)


func _on_acceleration_up_pressed() -> void:
	CarStats.add_accel(0.5)


func _on_handling_up_pressed() -> void:
	CarStats.add_handle(0.2)


func _on_exit_pressed() -> void:
	StageLoader.advance_stage()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Car:
		$GarageCam.make_current()
		StageLoader.complete_stage()
