class_name Garage
extends Node3D

@onready var area: Area3D = $Area3D
@onready var car: Node3D = $Car
@onready var sprite: Sprite3D = $Area3D/CollisionShape3D/Sprite3D
@onready var upgrade_panel: UpgradePanel = $UpgradeMenu/SubViewport/UpgradePanel


func _ready():
	set_active(false)
	car.hide()


func set_active(active: bool = true):
	area.visible = active
	area.monitoring = active
	upgrade_panel.visible = active


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Car && StageLoader.stage.active:
		AudioManager.play_music(preload("res://assets/music/asleep.mp3"))
		upgrade_panel.set_time_left(StageLoader.stage.timer)

		UILayer.transition_overlay.trigger()
		await UILayer.transition_overlay.halfway
		
		car.show()
		$GarageCam.make_current()
		StageLoader.complete_stage()
