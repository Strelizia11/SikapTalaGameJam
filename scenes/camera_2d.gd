extends Camera2D

@export var pan_speed := 200.0
@export var max_offset := 150.0
@export var edge_size := 200.0
@export var return_speed := 1.5

func _process(delta):
	var mouse_x = get_viewport().get_mouse_position().x
	var screen_width = get_viewport_rect().size.x

	# Pan left
	if mouse_x < edge_size:
		offset.x -= pan_speed * delta

	# Pan right
	elif mouse_x > screen_width - edge_size:
		offset.x += pan_speed * delta

	# Slowly return to center
	else:
		offset.x = lerp(offset.x, 0.0, return_speed * delta)

	# Prevent too much movement
	offset.x = clamp(offset.x, -max_offset, max_offset)
