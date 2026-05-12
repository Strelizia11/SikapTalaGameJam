# GlobalTimer.gd
extends Timer

func _ready():
	wait_time = 60.0 # Set your countdown time
	one_shot = true
	start()

func get_time_left_formatted() -> String:
	return "%02d:%02d" % [floor(time_left / 60), int(time_left) % 60]
