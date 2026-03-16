class_name Enemy
extends CharacterBody3D

@export var enemy_groups: Array[String] = []
@export var max_health: float = 100.0

var health: float


func _ready():
	health = max_health
	for group in enemy_groups:
		add_to_group(group)


func damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		queue_free()


func on_triggered():
	pass
