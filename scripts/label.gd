extends Label

@onready var time_label = $Label

func _process(_delta):
	# Access the GlobalTimer directly by its name
	time_label.text = GlobalTimer.get_time_left_formatted()
