class_name Explosion
extends Node3D


func start(target_node: Node3D):
	target_node.add_sibling(self )
	global_position = target_node.global_position
	show()
	print("Explosion at ", global_position)
	AudioManager.play_sound_3d(preload("res://assets/sfx/explosion.ogg"), global_position, 15.0)


func _on_animated_sprite_3d_animation_finished():
	hide()
	queue_free()
