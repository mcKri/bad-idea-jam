class_name Enemy
extends CharacterBody3D

const DEATH_EXPLOSION_SCENE := preload("res://entities/explosion/explosion.tscn")

@export var enemy_groups: Array[String] = []
@export var max_health: float = 70.0

var health: float


func _ready():
	if not is_visible_in_tree():
		queue_free()

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
	var explosion: Explosion = DEATH_EXPLOSION_SCENE.instantiate()
	explosion.start(self )
	queue_free()
