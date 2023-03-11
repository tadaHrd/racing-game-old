extends VehicleBody

onready var BL = $back_left
onready var BR = $back_right
onready var FL = $front_left
onready var FR = $front_right
onready var cam = $Cam_Pivot
onready var cam_arm = $Cam_Pivot/Camera_arm
onready var car = $"."
onready var engineSound = $EngineSoundPlayer
onready var nametag = $NameTag

export var          max_rpm = 1500
export var       back_speed = 0.75
export var           torque = 200
export var brake_multiplier = 3
export var        max_steer = 0.4 #0-1
export var     brake_amount = 4
export var       cam_smooth = 0.1

var rpm = 0
var lock = 0
var locked = 0
var lock_mod = 0
var locked_rpm
var mouse_mode = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	rpm = (BL.get_rpm() + BR.get_rpm()) / 2
	
	player_name()
	set_mouse_mode()
	control_car(get_speed_for_car(), get_speed_for_car(), Input.get_action_strength("brake") * brake_amount, Input.get_axis("right", "left"))
	control_camera()
	sound()
	dont_fall()
	lock_rpm()

func get_speed_for_car() -> float:
	var speed
	
	if rpm > 0:
		speed = Input.get_action_strength("forward") - Input.get_action_strength("back") * brake_multiplier
	else:
		speed = Input.get_action_strength("forward") * brake_multiplier - Input.get_action_strength("back") * back_speed
	
	if abs(rpm) >= max_rpm:
		speed = 0
	
	return speed * torque

func control_car(R, L, brake_amount, steer_axis, front_wheels: bool = true, back_wheels: bool = true):
	if lock_mod == 0:
		if back_wheels:  BL.engine_force = L 
		if back_wheels:  BR.engine_force = R
		if front_wheels: FL.engine_force = L
		if front_wheels: FR.engine_force = R
	if lock_mod == 1 && lock_mod >= 0:
		if rpm < locked_rpm:
			BL.engine_force = torque
			BR.engine_force = torque
			FL.engine_force = torque
			FR.engine_force = torque
		else:
			BL.engine_force = 0
			BR.engine_force = 0
			FL.engine_force = 0
			FR.engine_force = 0
	if lock_mod == 1 && locked_rpm < 0:
		if rpm > locked_rpm:
			BL.engine_force = -torque * back_speed
			BR.engine_force = -torque * back_speed
			FL.engine_force = -torque * back_speed
			FR.engine_force = -torque * back_speed
		else:
			BL.engine_force = 0
			BR.engine_force = 0
			FL.engine_force = 0
			FR.engine_force = 0
	
	steering = lerp(steering, steer_axis * max_steer, 0.2)
	
	brake = brake_amount

func sound():
	engineSound.set_max_db(abs(rpm) / 60)
	engineSound.pitch_scale = abs(rpm / 600)
	engineSound._set_playing(true)

func control_camera():
	if rpm < 0:
		cam.rotation.y = lerp(cam.rotation.y, PI, cam_smooth)
	else:
		cam.rotation.y = lerp(cam.rotation.y, 0, cam_smooth)
	
	cam.rotation.y = lerp(cam.rotation.y, cam.rotation.y + Input.get_axis("look_left", "look_right") * PI / 2, cam_smooth)

func dont_fall():
	if transform.origin.y <= -1:
		transform.origin = Vector3.UP

func player_name():
	nametag.text = car.name

func lock_rpm():
	if Input.is_action_just_pressed("lock_rpm"):
		lock += 1
		locked += 1
	if int(locked) % 2 == 1: locked_rpm = rpm; locked = 0
	lock_mod = lock % 2

func set_mouse_mode():
	if Input.is_action_just_pressed("escape"):
		mouse_mode += 1
	
	if Input.is_action_just_pressed("clickin"):
		mouse_mode = 0
	
	if mouse_mode % 2 == 1: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
