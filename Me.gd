extends KinematicBody

var timer = 0
var spector_index = 0
var spectator_username = ""
var health = 100
var score_a = 0
var score_b = 0
var team = 0
var deaths = 0
var kills = 0
var game_mode = 0
var game_round = 0
var skin = 0
var current_weapon = 0
var weapon_1 = 0
var weapon_2 = 0
var weapon_3 = 0
var weapon_4 = 0
var weapon_5 = 0
var current_ammo = 0
var ammo_1 = 0
var ammo_2 = 0
var ammo_3 = 0
var ammo_4 = 0
var ammo_5 = 0
var afk_counter = 7000
var mouse_sensitivity = null
export var magnitude: float = 8.0
var jumps_made = 0
var input_direction =  Vector3()
var look_y = Vector3()
var local_gravity = Vector3()

onready var pivot = get_node("camera_root")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	health = 100
	global_transform.origin = Vector3(0,10,0)
	if mouse_sensitivity == null:
		mouse_sensitivity = get_parent().get_parent().data_to_save["mouse_sensitivity"]
		
func respawn():
	health = 100
	global_transform.origin = Vector3(0,10,0)
	
func _input(event):
	
	if  event is InputEventMouseMotion and mouse_sensitivity:
		rotate_y(-1 * deg2rad(event.relative.x * mouse_sensitivity))
		pivot.rotate_x(deg2rad(-event.relative.y) * mouse_sensitivity)
		pivot.rotation.x = clamp(pivot.rotation.x, deg2rad(-89), deg2rad(89))
		look_y = clamp(sin(pivot.rotation.x), -1, 1)
		look_y = range_lerp(look_y, -1, 1, -1.0, 1.0)
#		animation.set("parameters/look_angle", look_y)

func get_input_deriction():
	var z: float = (
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	var x: float = (
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	)
	return transform.basis.xform(Vector3(x,0,z)).normalized()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if health < 0:
		queue_free()
		set_process(false)
	else:
		input_direction = get_input_deriction()
		var heading = pivot.global_transform.basis
		local_gravity.y -= 9.8  * delta
		var is_falling = local_gravity.y > 0.0 and not is_on_floor()
		var is_jumping = Input.is_action_just_pressed("ui_select") and is_on_floor()
		var is_double_jumping = Input.is_action_just_pressed("ui_select") and is_falling
		var is_jump_cancelled = Input.is_action_just_pressed("ui_select") and local_gravity.y < 0.0
		var is_idling = is_on_floor() and (is_zero_approx(input_direction.x) and is_zero_approx(input_direction.z))
		var is_running = is_on_floor() and (not is_zero_approx(input_direction.x) and not is_zero_approx(input_direction.z))
		
		if is_jumping:
			jumps_made +=1
			local_gravity = Vector3.UP * 3.0
		elif is_double_jumping:
			jumps_made +=1
			if jumps_made <= 2:
				local_gravity = Vector3.UP * 2.0
		elif is_jump_cancelled:
			local_gravity = Vector3.ZERO
		elif is_idling or is_running:
			jumps_made = 0

		move_and_slide((input_direction + local_gravity) * magnitude, Vector3.UP)
		if is_jumping or is_double_jumping:
			#play animation of jump
			pass
		elif is_running:
			pass
		elif is_falling:
			pass
		elif is_idling:
			pass

	
#func _integrate_forces(state):
#		if not blocked:
#			if inputs == null:
#				inputs = get_parent().get_parent().inputs		
#			if inputs["forward"]:
#				add_force(Vector3.FORWARD * magnitude,global_transform.origin)
#			if not inputs["forward"]:
#				add_force(Vector3.FORWARD * 0,global_transform.origin)
#			if inputs["backward"]:
#				add_force(Vector3.BACK * magnitude,global_transform.origin)
#			if not inputs["backward"]:
#				add_force(Vector3.BACK * 0,global_transform.origin)
#			if inputs["left"]:
#				add_force(Vector3.LEFT * magnitude,global_transform.origin)
#			if not inputs["left"]:
#				add_force(Vector3.LEFT * 0,global_transform.origin)
#			if inputs["right"]:
#				add_force(Vector3.RIGHT * magnitude,global_transform.origin)
#			if not inputs["right"]:
#				add_force(Vector3.RIGHT * 0,global_transform.origin)
#			if inputs["jump"]:
#				apply_impulse(global_transform.origin, Vector3.UP * magnitude * 0.2)
