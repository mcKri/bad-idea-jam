class_name Garage
extends Node3D

@onready var area: Area3D = $Area3D
@onready var sprite: Sprite3D = $Area3D/CollisionShape3D/Sprite3D
@onready var upgrade_panel: UpgradePanel = $UpgradeMenu/SubViewport/UpgradePanel


func _ready():
	set_active(false)


func set_active(active: bool = true):
	area.visible = active
	area.monitoring = active
	upgrade_panel.visible = active


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Car:
		upgrade_panel.set_time_left(StageLoader.stage.timer)
		$GarageCam.make_current()
		StageLoader.complete_stage()
