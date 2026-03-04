class_name Car
extends Node3D

@onready var sphere: RigidBody3D = $Sphere
@onready var mesh: Node3D = $Mesh
@onready var ground_ray: RayCast3D = $Mesh/RayCast3D
@onready var body: CSGBox3D = $Mesh/CSGBox3D
@onready var camera_point: Marker3D = $CameraPoint
@onready var box_holder: BoxHolder = $Mesh/BoxHolder
@onready var car_body_shape: CollisionShape3D = $Sphere/CarBodyShape

@export var steer_speed_curve: Curve

const SPHERE_OFFSET := Vector3(0, -0.4, 0) # Where to place mesh relative to sphere center
const FRONT_AXLE_OFFSET := Vector3(0, 0, -0.25)

const ACCELERATION := 28.0
const REVERSE_FACTOR := 0.5 # Reverse strength relative to acceleration
const MAX_SPEED := 18.0
const STATIONARY_THRESHOLD := 0.5 # Speed below which the car is considered stationary

const HANDBRAKE_DRAG := 3.0
const GRIP := 10.0 # Maximum grip (no drift)
const MIN_GRIP := 1.5 # Minimum grip (max drift)
const HANDBRAKE_GRIP_REDUCTION := 4.0 # Grip lost when handbraking
const OVERSTEER_GRIP_SCALE := 6.0 # How much oversteer angle reduces grip (per radian)

const STEERING := deg_to_rad(16.0) # How much the mesh rotates per steering input
const TURN_SPEED := 8.0 # How quickly the mesh rotates to match steering input
const DRIFT_STEER_MULT := 1.5 # Extra mesh rotation multiplier while drifting

const MAX_TILT := 1.2
const TILT_LEAN_SPEED := 2.0 # How quickly the body tilts into a drift
const TILT_RECOVER_SPEED := 15.0 # How quickly the body returns upright

var speed_input := 0.0
var steer_input := 0.0
var handbrake := false


func _ready():
	ground_ray.add_exception(sphere)


func _physics_process(delta):
	# Pin front axle to sphere
	mesh.global_position = sphere.global_position + SPHERE_OFFSET - mesh.global_basis * FRONT_AXLE_OFFSET

	# Throttle / brake
	sphere.apply_central_impulse(-mesh.global_basis.z * speed_input * delta)

	# Handbrake drag
	if handbrake:
		sphere.apply_central_force(-sphere.linear_velocity * HANDBRAKE_DRAG)

	# Rotate mesh for steering
	var speed := sphere.linear_velocity.length()
	var forward := -mesh.global_basis.z
	var speed_factor := minf(speed / MAX_SPEED, 1.0)
	var steer_strength := steer_speed_curve.sample(speed_factor) if steer_speed_curve else 1.0
	
	# Measure angle between mesh facing and velocity (drift angle)
	var drift_angle := 0.0
	var vel_dir := sphere.linear_velocity.normalized()
	if speed > STATIONARY_THRESHOLD:
		var facing := forward if not is_reversing() else -forward
		drift_angle = facing.signed_angle_to(vel_dir, Vector3.UP)
	
	# Continuous grip reduced by oversteer angle and handbrake
	var grip_loss := absf(drift_angle) * OVERSTEER_GRIP_SCALE
	if handbrake:
		grip_loss += HANDBRAKE_GRIP_REDUCTION
	var current_grip := clampf(GRIP - grip_loss, MIN_GRIP, GRIP)
	var is_drifting := current_grip < GRIP - 0.5
	
	# Amplify steering while drifting
	var steer_mult := DRIFT_STEER_MULT if is_drifting else 1.0
	mesh.rotate_y(steer_input * TURN_SPEED * steer_strength * steer_mult * delta * (-1.0 if is_reversing() else 1.0))
	
	# Grip: steer the sphere's velocity toward the mesh's forward direction
	var grip_dir := forward * speed if not is_reversing() else -forward * speed
	var grip_force := (grip_dir - sphere.linear_velocity) * current_grip
	sphere.apply_central_force(grip_force)

	# Speed cap
	if speed > get_max_speed():
		sphere.linear_velocity = sphere.linear_velocity.normalized() * get_max_speed()
	
	# Body tilt from drift angle
	if is_reversing() || is_stationary():
		body.rotation.z = lerp(body.rotation.z, 0.0, TILT_RECOVER_SPEED * delta)
	else:
		var tilt_target := drift_angle * speed_factor * MAX_TILT
		var tilt_speed := lerpf(TILT_RECOVER_SPEED, TILT_LEAN_SPEED, absf(drift_angle) / PI)
		body.rotation.z = lerp(body.rotation.z, tilt_target, tilt_speed * delta)
	
	# Lead camera point
	var camera_offset := Vector3(0, 3.0, 0) + vel_dir * 5.0 * speed_factor
	camera_offset *= speed_factor * (1.0 if not is_reversing() else -1.0)
	camera_point.global_position = lerp(camera_point.global_position, mesh.global_position + camera_offset, 5.0 * delta)

	# Anchor car body shape to mesh for collisions
	# car_body_shape.global_transform = mesh.global_transform
	# car_body_shape.global_position.y += 1.0
	

func _process(_delta):
	speed_input = (Input.get_action_strength("accelerate") - Input.get_action_strength("reverse") * REVERSE_FACTOR) * ACCELERATION
	steer_input = (Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")) * STEERING
	handbrake = Input.is_action_pressed("handbrake")


func is_reversing() -> bool:
	if is_stationary():
		return false
	
	var speed := sphere.linear_velocity.length()
	var vel_dir := sphere.linear_velocity / speed
	var forward_dot := (-mesh.global_basis.z).dot(vel_dir)
	
	return forward_dot < 0.0


func is_stationary() -> bool:
	var speed := sphere.linear_velocity.length()
	return speed < STATIONARY_THRESHOLD


func get_max_speed() -> float:
	return MAX_SPEED * (REVERSE_FACTOR if is_reversing() else 1.0)
