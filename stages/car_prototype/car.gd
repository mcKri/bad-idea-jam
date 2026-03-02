extends Node3D

@onready var sphere: RigidBody3D = $Sphere
@onready var sphere_shape: CollisionShape3D = $Sphere/CollisionShape3D
@onready var mesh: Node3D = $Mesh
@onready var ground_ray: RayCast3D = $Mesh/RayCast3D
@onready var body: CSGBox3D = $Mesh/Body

# Where to place mesh relative to sphere
const SPHERE_OFFSET := Vector3(0, -1.0, 0)
# Engine power
const ACCELERATION := 50.0
# Turn amount in degrees
const STEERING := 16.0
# How quickly the car turns
const TURN_SPEED := 5.0
# Minimum speed threshold to allow turning
const TURN_STOP_LIMIT := 0.75
# Amount to tilt on turns
const BODY_TILT := 25.0

var speed_input := 0.0
var rotate_input := 0.0


func _ready():
	ground_ray.add_exception(sphere)


func _physics_process(delta):
	mesh.transform.origin = sphere.transform.origin + SPHERE_OFFSET
	sphere.apply_central_impulse(-mesh.global_basis.z * speed_input * delta)


func _process(delta):
	#if !ground_ray.is_colliding():
		#print("NOT ON FLOOR")
		#return
	
	speed_input = 0
	speed_input += Input.get_action_strength("accelerate")
	speed_input -= Input.get_action_strength("brake")
	speed_input *= ACCELERATION

	rotate_input = 0
	rotate_input += Input.get_action_strength("steer_left")
	rotate_input -= Input.get_action_strength("steer_right")
	rotate_input *= deg_to_rad(STEERING)
	
	# Oversteer mesh
	if sphere.linear_velocity.length() > TURN_STOP_LIMIT:
		var new_basis = mesh.global_basis.rotated(mesh.global_basis.y, rotate_input)
		mesh.global_basis = mesh.global_basis.slerp(new_basis, TURN_SPEED * delta)
		mesh.global_transform = mesh.global_transform.orthonormalized()
		
		var t = -rotate_input * sphere.linear_velocity.length() / BODY_TILT
		body.rotation.z = lerp(body.rotation.z, t, 10 * delta)
