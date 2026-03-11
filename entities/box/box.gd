class_name Box
extends RigidBody3D

@onready var stack_anchor: Marker3D = $StackAnchor


func enable_interaction(val: bool):
	set_collision_layer_value(6, val)


func drop():
	reparent(StageLoader.stage)
	freeze = false
	enable_interaction(true)
	UILayer.hud.screen_pointer.add_target(self )
