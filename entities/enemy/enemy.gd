class_name Enemy
extends CharacterBody3D

const DEATH_EXPLOSION_SCENE := preload("res://entities/explosion/explosion.tscn")

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
		die()


func on_triggered():
	pass


func die():
	var explosion = DEATH_EXPLOSION_SCENE.instantiate()
	add_sibling(explosion)
	explosion.global_position = global_position
	queue_free()
