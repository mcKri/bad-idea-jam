class_name Bullet
extends Area3D

const SPEED := 80.0

var _damage := 10.0


func _ready():
	hide()


func fire(direction: Vector3, damage: float = _damage):
	_damage = damage
	look_at(global_transform.origin + direction, Vector3.UP)
	monitoring = true
	visible = true


func _physics_process(delta: float):
	if not visible:
		return

	translate(Vector3.FORWARD * SPEED * delta)


func _on_body_entered(body: Node3D):
	if !body.is_visible_in_tree():
		return
	
	if body is Player:
		body.damage(_damage)
	
	if body is Car:
		body.damage(_damage)

	if body is Enemy:
		# TODO: Damage enemy
		pass

	queue_free()


func _on_area_entered(area: Area3D):
	if !area.is_visible_in_tree():
		return
	
	# Check if car body
	if area.get_collision_layer_value(2):
		var parent = area.get_parent().get_parent()
		if parent is Car:
			parent.damage(_damage)
	
	queue_free()
