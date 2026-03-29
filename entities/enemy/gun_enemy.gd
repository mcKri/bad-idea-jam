class_name GunEnemy
extends Enemy

const VISION_CONE_ANGLE: float = 20
const ANGLE_BETWEEN_RAYS: float = 2.5
const MAX_VIEW_DIST: float = 100

const SHOOT_COOLDOWN := 1.5
const SHOOT_FORCE := 10.0
const STOP_DISTANCE := 8.0
const STOP_MARGIN := 2.0
const LAUNCH_FRICTION := 20.0
@export var bullet_scene: PackedScene

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var state_chart: StateChart = $StateChart
@onready var sprite: Sprite3D = $Sprite3D

@onready var detect_area: Area3D = $DetectionArea
@onready var detect_shape: CollisionShape3D = $DetectionArea/CollisionShape3D
@onready var sight_cast: RayCast3D = $SightCast

@export var follow_speed := 3.0

var target: Node3D
var _shoot_timer: float = 0.0
var _at_stop_distance := false
var _launch_velocity: Vector3 = Vector3.ZERO

var _debug_draw := false
var _debug_mesh: ImmediateMesh
var _debug_mesh_instance: MeshInstance3D


func _ready():
	super ()

	detect_shape.shape = SphereShape3D.new()
	detect_shape.shape.radius = MAX_VIEW_DIST

	nav_agent.velocity_computed.connect(_on_velocity_computed)

	if OS.is_debug_build() && _debug_draw:
		_debug_mesh = ImmediateMesh.new()
		_debug_mesh_instance = MeshInstance3D.new()
		_debug_mesh_instance.mesh = _debug_mesh
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.vertex_color_use_as_albedo = true
		_debug_mesh_instance.material_override = mat
		add_child(_debug_mesh_instance)


func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	
	move_and_slide()
	if velocity.length() > 0:
		sprite.rotation.y = atan2(velocity.x, velocity.z) - rotation.y - PI / 2.0


func _draw_debug_ray(cast_vector: Vector3) -> void:
	var ray_start := _debug_mesh_instance.to_local(sight_cast.global_position)
	var ray_end: Vector3
	var color: Color
	
	if sight_cast.is_colliding():
		ray_end = _debug_mesh_instance.to_local(sight_cast.get_collision_point())
		var coll = sight_cast.get_collider()
		color = Color.GREEN if (coll is Player or coll is Car) else Color.RED
	else:
		ray_end = _debug_mesh_instance.to_local(sight_cast.to_global(cast_vector))
		color = Color.YELLOW
	
	_debug_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	_debug_mesh.surface_set_color(color)
	_debug_mesh.surface_add_vertex(ray_start)
	_debug_mesh.surface_set_color(color)
	_debug_mesh.surface_add_vertex(ray_end)
	_debug_mesh.surface_end()


func search_for_player():
	if _debug_mesh:
		_debug_mesh.clear_surfaces()

	var cast_count := int(VISION_CONE_ANGLE / ANGLE_BETWEEN_RAYS) + 1
	var detected_bodies := detect_area.get_overlapping_bodies()

	# Sort detected bodies by distance to the caster
	detected_bodies.sort_custom(func(a, b):
		var distance_to_a = a.global_position.distance_squared_to(global_position)
		var distance_to_b = b.global_position.distance_squared_to(global_position)
		return distance_to_a < distance_to_b
	)

	for body in detected_bodies:
		if body is not Player:
			continue
		
		var dir_to_body = body.global_position - sight_cast.global_position
		dir_to_body.y = 0
		var base_angle = atan2(dir_to_body.x, dir_to_body.z)

		for i in cast_count:
			var angle = base_angle + deg_to_rad(ANGLE_BETWEEN_RAYS) * (i - (cast_count - 1) / 2.0)
			var world_dir = Vector3(sin(angle), 0, cos(angle)) * MAX_VIEW_DIST
			var cast_vector = sight_cast.to_local(sight_cast.global_position + world_dir)
			sight_cast.target_position = cast_vector
			sight_cast.force_raycast_update()
			
			if _debug_mesh:
				_draw_debug_ray(cast_vector)
			
			if !sight_cast.is_colliding():
				continue
			
			var collider = sight_cast.get_collider()
			if collider is Area3D:
				collider = collider.get_parent().get_parent()
			if collider is Player || collider is Car:
				target = body
				_on_triggered()
				return
			

func _check_target_visible() -> bool:
	if not target:
		return false
	
	var dir := target.global_position - sight_cast.global_position
	sight_cast.target_position = sight_cast.to_local(sight_cast.global_position + dir.normalized() * MAX_VIEW_DIST)
	sight_cast.force_raycast_update()
	if not sight_cast.is_colliding():
		return false
	
	var collider = sight_cast.get_collider()
	
	return collider is Player or collider is Car


func _shoot() -> void:
	if not bullet_scene:
		return
	var bullet: Bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = sight_cast.global_position + sight_cast.global_transform.basis.z * 1.5
	var dir := (target.global_position - sight_cast.global_position).normalized()
	bullet.fire(dir)


func launch(force: Vector3) -> void:
	_launch_velocity = Vector3(force.x, 0.0, force.z)
	state_chart.send_event("toLaunched")


func _on_triggered():
	state_chart.send_event("toFollow")


func _on_velocity_computed(safe_velocity: Vector3):
	if _launch_velocity != Vector3.ZERO:
		return
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z


func _on_follow_state_physics_processing(delta: float):
	if not target:
		return

	_shoot_timer -= delta
	if _shoot_timer <= 0.0 and _check_target_visible():
		_shoot()
		_shoot_timer = SHOOT_COOLDOWN

	var dist_to_target := global_position.distance_to(target.global_position)
	if _at_stop_distance:
		if dist_to_target > STOP_DISTANCE + STOP_MARGIN:
			_at_stop_distance = false
	else:
		if dist_to_target <= STOP_DISTANCE:
			_at_stop_distance = true

	if _at_stop_distance:
		nav_agent.velocity = Vector3.ZERO
		return

	nav_agent.target_position = target.global_position

	if nav_agent.is_navigation_finished():
		nav_agent.velocity = Vector3.ZERO
		return

	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	nav_agent.velocity = direction * follow_speed

	if direction.length() > 0.01:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 5.0 * delta)


func _on_idle_state_physics_processing(_delta: float):
	search_for_player()


func _on_launched_state_state_physics_processing(delta: float):
	nav_agent.velocity = Vector3.ZERO
	var speed := _launch_velocity.length()

	# Check for non-floor collisions and deal self-damage on impact
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var other := col.get_collider()

		# Only apply damage and stop launch when hitting something that isn't the floor
		if other is CSGBox3D || other is Car || other is Player:
			continue
		
		die()
		return

	velocity.x = _launch_velocity.x
	velocity.z = _launch_velocity.z

	if speed > 0.0:
		var new_speed := maxf(0.0, speed - LAUNCH_FRICTION * delta)
		_launch_velocity = _launch_velocity * (new_speed / speed)

	if speed < 0.5:
		_launch_velocity = Vector3.ZERO
		state_chart.send_event("toIdle")
