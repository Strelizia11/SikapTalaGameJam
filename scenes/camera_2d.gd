extends Camera2D

@export var pan_speed := 200.0
@export var max_offset := 150.0
@export var edge_size := 200.0
@export var return_speed := 1.5

var can_pan := false  # OFF during menu

func _process(delta):
	# MENU STATE: freeze camera
	if !can_pan:
		offset.x = lerp(offset.x, 0.0, return_speed * delta)
		return

	# PLAY STATE: edge-based panning
	var mouse_x = get_viewport().get_mouse_position().x
	var screen_width = get_viewport_rect().size.x

	# Left edge
	if mouse_x < edge_size:
		offset.x -= pan_speed * delta

	# Right edge
	elif mouse_x > screen_width - edge_size:
		offset.x += pan_speed * delta

	# Return to center when idle
	else:
		offset.x = lerp(offset.x, 0.0, return_speed * delta)

	# Clamp movement
	offset.x = clamp(offset.x, -max_offset, max_offset)
