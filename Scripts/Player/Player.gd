extends KinematicBody

const speed = 10
const ACCEL_DEFAULT = 5
const ACCEL_AIR = 4
const DASH_SPEED = 25
const THROW_FORCE = 30

onready var accel = ACCEL_DEFAULT
var gravity = 9.8
var jump = 5

var cam_accel = 40
var mouse_sense = 0.2
var snap

var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

var is_dead = false

var was_in_air = false
var prev_gravity = 0

var can_dash = true
var dashing = false

var can_throw = true

var sliding = false
var can_slide = true

var can_grapple = true
var grappling = false
var hookpoint = Vector3()
var hookpoint_get = false
var fingergun_animation_done = false

var wallrunning = false

onready var head = $Head
onready var camera = $Head/Camera
onready var crosshair = $Crosshair
onready var grapplecast = $Head/GrappleRay
onready var throwable = preload("res://Scenes/Player/Throwable.tscn")

func grapple():
	if Input.is_action_just_released("grapple") and not fingergun_animation_done and grapplecast.is_colliding():
		$Head/FingerGun/AnimationPlayer.play("put_down")
	if Input.is_action_pressed("grapple"):
		if grapplecast.is_colliding():
			if not grappling:
				if can_grapple:
					if not fingergun_animation_done:
						$Head/FingerGun/AnimationPlayer.play("pull_up")
					else:
						grappling = true
						can_grapple = false
						$Timers/GrappleTimer.start()
						$GrapplingHook/GrappleLine.visible = true
						$GrapplingHook/Hook.visible = true
	else:
		if grappling:
			snap = Vector3.ZERO
			# launch at the end of grapple
			gravity_vec = (hookpoint - transform.origin).normalized() * jump * 2
		grappling = false
		hookpoint_get = false
		$GrapplingHook/GrappleLine.visible = false
		
	if grappling:
		gravity_vec.y = 0
		if not hookpoint_get:
			var object = grapplecast.get_collider()
			if object.is_in_group("Throwable"):
				object.grab()
			
			var hitpoint = grapplecast.get_collision_point()
			hookpoint = hitpoint + Vector3(0, 1, 0)
			var adjustment = (hitpoint - transform.origin).normalized() * 5
			$GrapplingHook/GrappleLine.set_point_position(1, hitpoint + adjustment)
			$GrapplingHook/Hook.global_transform.origin = hitpoint
			$GrapplingHook/Hook.rotation_degrees = Vector3(rand_range(0, 180), rand_range(0, 180), rand_range(0, 180))
			hookpoint_get = true
		if hookpoint.distance_to(transform.origin) > 5:
			if hookpoint_get:
				transform.origin = lerp(transform.origin, hookpoint, 0.05)

func dash():
	if Input.is_action_just_pressed("dash") and can_dash:
		$GUI/SpeedLines.visible = true
		dashing = true
		$Timers/DashLineTimer.start()
		can_dash = false
		$Timers/DashTimer.start()
		var vec = ($Head/DashTarget.global_transform.origin - transform.origin).normalized()
		velocity += vec * DASH_SPEED

func wallrun():
	var right = $WallrunRays/Right.is_colliding()
	var left = $WallrunRays/Left.is_colliding()
	if Input.is_action_pressed("jump") and Input.is_action_pressed("w") and is_on_wall() \
	and (left or right) and (abs(velocity.x) + abs(velocity.z)) > 6:
		gravity_vec.y = 1
		wallrunning = true
		if right: $GUI/RightNotifier.visible = true
		if left: $GUI/LeftNotifier.visible = true
	else:
		#jump on wallrun end
		if wallrunning:
			snap = Vector3.ZERO
			var wallpoint
			if right:
				wallpoint = $WallrunRays/Right.get_collision_point()
			elif left:
				wallpoint = $WallrunRays/Left.get_collision_point()
			else:
				wallpoint = null
			if wallpoint != null:
				var vec = (transform.origin - wallpoint).normalized() * jump
				gravity_vec = vec
		wallrunning = false
		$GUI/RightNotifier.visible = false
		$GUI/LeftNotifier.visible = false

func throw():
	if Input.is_action_just_released("throw") and can_throw:
		can_throw = false
		$Timers/ThrowableTimer.start()
		var t = throwable.instance()
		var force = ($Head/Throwable/TargetPosition.global_transform.origin - \
			$Head/Throwable/StartPosition.global_transform.origin).normalized() * THROW_FORCE
		t.transform.origin = $Head/Throwable/StartPosition.transform.origin
		t.set_as_toplevel(true)
		t.apply_central_impulse(force)
		add_child(t)

func slide():
	if Input.is_action_pressed("slide") and can_slide:
		camera.shake()
#		scale.y = .3
#		$GUI/TopNotifier.visible = true
#		$Timers/SlideTimer.start()
#		can_slide = false
#		sliding = true
#		var vec = ($Head/DashTarget.global_transform.origin - transform.origin).normalized()
#		velocity += vec * DASH_SPEED

func climb():
	var can_climb = $ClimbRays/Bottom.is_colliding() and not $ClimbRays/Top.is_colliding()
	if Input.is_action_pressed("w") or Input.is_action_pressed("jump"):
		if can_climb:
			$GUI/BottomNotifier.visible = true
			$Timers/ClimbTimer.start()
			gravity_vec = ($ClimbRays/Bottom.get_collision_point() + Vector3(0, 2, 0) - transform.origin).normalized() * jump

func tilt_head():
	if Input.is_action_pressed("a"):
		camera.rotation_degrees.z = lerp(camera.rotation_degrees.z, 3, .1)
	elif Input.is_action_pressed("d"):
		camera.rotation_degrees.z = lerp(camera.rotation_degrees.z, -3, .1)
	else:
		camera.rotation_degrees.z = lerp(camera.rotation_degrees.z, 0, .1)

func camera_shake():
	if was_in_air and is_on_floor() and prev_gravity <= -10:
		camera.shake()
	was_in_air = !is_on_floor()
	prev_gravity = gravity_vec.y

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$Debug/Monitor.os_time_per_frame()
	$Debug/Monitor.add_perf_monitor(Performance.TIME_FPS)
	$Debug/Monitor.add_perf_monitor(Performance.TIME_PHYSICS_PROCESS)
	$Debug/Monitor.add_perf_monitor(Performance.MEMORY_DYNAMIC)
	$Debug/Monitor.add_perf_monitor(Performance.RENDER_OBJECTS_IN_FRAME)
	$Debug/Monitor.add_perf_monitor(Performance.RENDER_VERTICES_IN_FRAME)
	$Debug/Monitor.add_perf_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME)

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

func _process(delta):
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	#interferes w head tilt
#	if Engine.get_frames_per_second() > Engine.iterations_per_second:
#		camera.set_as_toplevel(true)
#		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
#		camera.rotation.y = rotation.y
#		camera.rotation.x = head.rotation.x
#	else:
#		camera.set_as_toplevel(false)
#		camera.global_transform = head.global_transform
	
	#scale fov based on speed
	var target = abs(velocity.x) + abs(velocity.z)
	camera.fov = lerp(camera.fov, clamp(90 + target, 90, 120), 1)
		
	tilt_head()
	$GUI/GrappleIcon.visible = can_grapple
	$GUI/DashIcon.visible = can_dash
	$GUI/ThrowableIcon.visible = can_throw
		
func _physics_process(delta):
	if not is_dead:
		crosshair.visible = grapplecast.is_colliding()
		
		#get keyboard input
		direction = Vector3.ZERO
		var h_rot = global_transform.basis.get_euler().y
		var f_input = Input.get_action_strength("s") - Input.get_action_strength("w")
		var h_input = Input.get_action_strength("d") - Input.get_action_strength("a")
		direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
		
		#jumping and gravity
		if is_on_floor() and not grappling:
			snap = -get_floor_normal()
			accel = ACCEL_DEFAULT
			gravity_vec = Vector3.ZERO
		else:
			snap = Vector3.DOWN
			accel = ACCEL_AIR
			gravity_vec += Vector3.DOWN * gravity * delta
			
		if Input.is_action_just_pressed("jump") and is_on_floor():
			snap = Vector3.ZERO
			gravity_vec = Vector3.UP * jump
			
		$GrapplingHook/GrappleLine.set_point_position(0, $Head/FingerGun/Muzzle.global_transform.origin)
		grapple()
		wallrun()
		dash()
		throw()
		slide()
		climb()
		camera_shake()
	
	#make it move
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	movement = velocity + gravity_vec
	move_and_slide_with_snap(movement, snap, Vector3.UP)
	
	debug()
	
# FUNCTIONS YOU CALL FROM OUTSIDE 

func in_water(entered):
	if entered:
		$GUI/Water/Tween.interpolate_property($GUI/Water, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, .25), .5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	else:
		$GUI/Water/Tween.interpolate_property($GUI/Water, "modulate", Color(1, 1, 1, .25), Color(1, 1, 1, 0), .5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$GUI/Water/Tween.start()
	
func die():
	camera.shake()
	$GUI/Blood.visible = true
#	is_dead = true
	$Timers/DeathTimer.start()

# -----------------------------------

func debug():
	$Debug/Grappling.text = "grappling: " + str(grappling)
	$Debug/Wallrunning.text = "wallrunning: " + str(wallrunning)
	$Debug/Vectors.text = "velocity: " + str(velocity) + "\ngravity: " + str(gravity_vec)
	$Debug/FOV.text = "FOV: " + str(camera.fov)
	$Debug/CamRot.text = "camera rotation: " + str(camera.rotation_degrees.z)
	$Debug/GunAnim.text = "gun animation done: " + str(fingergun_animation_done)
	$Debug/Climbing.text = str($ClimbRays/Bottom.is_colliding() and not $ClimbRays/Top.is_colliding())
	$Debug/FPS.text = "FPS: " + str(Engine.get_frames_per_second())

# TIMERS ----------------

func _on_DashLineTimer_timeout():
	$GUI/SpeedLines.visible = false


func _on_GrappleTimer_timeout():
	can_grapple = true
	$GrapplingHook/GrappleLine.visible = false
	$GrapplingHook/Hook.visible = false
	$Head/FingerGun/AnimationPlayer.play("put_down")

func _on_DashTimer_timeout():
	can_dash = true
	dashing = false


func _on_ThrowableTimer_timeout():
	can_throw = true


func _on_SlideTimer_timeout():
	$GUI/TopNotifier.visible = false
	can_slide = true
	sliding = false
	scale.y = 1


func _on_FingerGunAnimationPlayer_animation_finished(anim_name):
	if anim_name == "pull_up":
		fingergun_animation_done = true
	if anim_name == "put_down":
		fingergun_animation_done = false


func _on_ClimbTimer_timeout():
	$GUI/BottomNotifier.visible = false


func _on_DeathTimer_timeout():
	# TODO checkpoint
	$GUI/Blood.visible = false
	get_tree().reload_current_scene()
