tool
extends Viewport

var car_rpm
var text

onready var BLW = $"../../../back_left"
onready var BRW = $"../../../back_right"

func _process(delta):
	$"../../".margin_left = OS.window_size.x / 2 - 75
	$"../../".margin_top = OS.window_size.y - 40
	$"../../".margin_right = OS.window_size.x / 2 + 75
	$"../../".margin_bottom = OS.window_size.y
	
	
	car_rpm = (BRW.get_rpm() + BLW.get_rpm()) / 2
	
	if car_rpm >= 1490:
		text = 1500
	elif car_rpm <= -1490:
		text = -1500
	elif abs(car_rpm) < 2:
		text = 0
	else:
		text = car_rpm
	
	size = $"../..".rect_size
	
	$"../".text = "RPM: " + str(floor(text))
