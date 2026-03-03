class_name Car
extends Node3D

@onready var sphere: RigidBody3D = $Sphere
@onready var mesh: Node3D = $Mesh
@onready var ground_ray: RayCast3D = $Mesh/RayCast3D
@onready var body: CSGBox3D = $Mesh/Body

const SPHERE_OFFSET := Vector3(0, -1.0, 0) # Where to place mesh relative to sphere center
const FRONT_AXLE_OFFSET := Vector3(0, 0, -0.25)

const ACCELERATION := 35.0
const MAX_SPEED := 20.0
const BRAKE_FACTOR := 0.5 # Brake strength relative to acceleration

const STEERING := deg_to_rad(16.0)
const TURN_SPEED := 3.0
const TURN_STOP_LIMIT := 0.75
# TODO: FIX DRIFT_MULT_FORWARD affecting turn speed instead of being purely visual
const DRIFT_MULT_FORWARD := 8.0 # How much steering offsets the mesh from velocity when going forward
const DRIFT_MULT_REVERSE := 2.0 # Same, when reversing

const MAX_TILT := 1.2
const TILT_LEAN_SPEED := 5.0 # How quickly the body tilts into a drift
const TILT_RECOVER_SPEED := 15.0 # How quickly the body returns upright

var speed_input := 0.0
var steer_input := 0.0


func _ready():
	ground_ray.add_exception(sphere)


func _physics_process(delta):
	# Pin front axle to sphere — rear swings out on drift
	mesh.global_position = sphere.global_position + SPHERE_OFFSET - mesh.global_basis * FRONT_AXLE_OFFSET

	# Throttle / brake
	sphere.apply_central_impulse(-mesh.global_basis.z * speed_input * delta)

	# Lateral steering impulse
	var speed := sphere.linear_velocity.length()
	if speed > TURN_STOP_LIMIT:
		var forward_dot := (-mesh.global_basis.z).dot(sphere.linear_velocity.normalized())
		var steer_dir := signf(forward_dot) if forward_dot != 0.0 else 1.0
		sphere.apply_central_impulse(mesh.global_basis.x * -steer_input * steer_dir * speed * TURN_SPEED * delta)

	# Speed cap
	if speed > MAX_SPEED:
		sphere.linear_velocity = sphere.linear_velocity.normalized() * MAX_SPEED


func _process(delta):
	speed_input = (Input.get_action_strength("accelerate") - Input.get_action_strength("brake") * BRAKE_FACTOR) * ACCELERATION
	steer_input = (Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")) * STEERING

	var speed := sphere.linear_velocity.length()
	if speed <= TURN_STOP_LIMIT:
		return

	var vel_dir := sphere.linear_velocity / speed
	var forward_dot := (-mesh.global_basis.z).dot(vel_dir)
	var is_reversing := forward_dot < 0.0

	# Choose target direction — reverse tracks backward, forward drifts
	var drift_mult := DRIFT_MULT_REVERSE if is_reversing else DRIFT_MULT_FORWARD
	var speed_factor := minf(speed / MAX_SPEED, 1.0)
	var base_dir := -vel_dir if is_reversing else vel_dir
	var steered_dir := base_dir.rotated(Vector3.UP, steer_input * drift_mult * speed_factor)

	# Rotate mesh toward target
	mesh.global_basis = mesh.global_basis.slerp(Basis.looking_at(steered_dir, mesh.global_basis.y), TURN_SPEED * delta)
	mesh.global_transform = mesh.global_transform.orthonormalized()

	# Body tilt from drift angle (forward only)
	if is_reversing:
		body.rotation.z = lerp(body.rotation.z, 0.0, TILT_RECOVER_SPEED * delta)
	else:
		var drift_angle := mesh.global_basis.z.signed_angle_to(-vel_dir, mesh.global_basis.y)
		var tilt_target := drift_angle * speed_factor * MAX_TILT
		var tilt_speed := lerpf(TILT_RECOVER_SPEED, TILT_LEAN_SPEED, absf(drift_angle) / PI)
		body.rotation.z = lerp(body.rotation.z, tilt_target, tilt_speed * delta)
