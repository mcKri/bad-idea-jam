class_name Player
extends CharacterBody3D

@onready var coll_shape: CollisionShape3D = $CollisionShape3D
@onready var direction_marker: Marker3D = $DirectionMarker
@onready var actionable_finder: Area3D = $DirectionMarker/ActionableFinder
@onready var carry_anchor: Marker3D = $DirectionMarker/CarryAnchor

var input_enabled := true
var first_actionable: Node3D = null:
	set(val):
		if val == first_actionable:
			return
		
		first_actionable = val
		if first_actionable:
			# TODO: Show UI prompt
			# TODO: Play SFX
			pass
		else:
			# TODO: Hide UI prompt
			pass

var car: Car
var held_box: Box

const MAX_HEALTH := 100.0
@onready var health_bar: HealthBar = $HealthBar
var health := MAX_HEALTH


func _ready():
	health_bar.set_maximum(MAX_HEALTH)


func _physics_process(delta):
	if !car && input_enabled:
		var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		velocity.x = input_vector.x * 500.0 * delta
		velocity.z = input_vector.y * 500.0 * delta
		move_and_slide()
		
		if velocity.length() > 0.1:
			direction_marker.look_at(global_position + velocity, Vector3.UP)
		
		# Check for actionable objects in front of the player
		var found_actionable = null
		for actionable in actionable_finder.get_overlapping_bodies():
			found_actionable = actionable
			if found_actionable == first_actionable:
				break
		
		first_actionable = found_actionable


func _unhandled_input(event: InputEvent):
	if !input_enabled:
		return
	
	if !car:
		if event is InputEventKey:
			if event.is_action_pressed("interact"):
				if first_actionable:
					if first_actionable is Box:
						carry_box(first_actionable)
					elif first_actionable is Car:
						if held_box:
							first_actionable.box_anchor.add_box(held_box)
							held_box = null
						else:
							enter_car(first_actionable)
				elif held_box:
					held_box.drop()
					held_box = null
	else:
		if event is InputEventKey:
			if event.is_action_pressed("interact"):
				exit_car()
	
	if event.is_action_pressed("restart_stage"):
		StageLoader.restart_stage()

	if event is InputEventKey:
		if Input.is_key_pressed(KEY_X):
			damage(50.0)


func enter_car(new_car: Car):
	car = new_car
	
	Camera.set_target(car.camera_point)
	UILayer.hud.screen_pointer.set_center_node(car.mesh)
	
	reparent(car.mesh)
	car.driving = true
	car.add_collision_exception_with(self )
	
	position = Vector3.ZERO
	visible = false
	actionable_finder.monitoring = false


func exit_car():
	Camera.set_target(self )
	UILayer.hud.screen_pointer.set_center_node(self )
	
	reparent(car.get_parent())
	car.driving = false
	car.remove_collision_exception_with(self )
	
	position = car.global_position - Vector3(2.0, 0, 0).rotated(Vector3.UP, car.mesh.global_rotation.y)
	rotation = Vector3.ZERO
	visible = true
	actionable_finder.monitoring = true
	
	car = null


func carry_box(box: Box):
	box.enable_interaction(false)
	box.freeze = true
	box.reparent(carry_anchor)
	box.transform = Transform3D.IDENTITY
	held_box = box


func damage(amount: float):
	health -= amount
	health_bar.update(health)
	if health <= 0.0:
		die()


func die():
	StageLoader.fail_stage("You died!")
	# TODO: Play animation
	hide()
	queue_free()
