extends Node

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F11:
			toggle_fullscreen()

func toggle_fullscreen():
	var mode = DisplayServer.window_get_mode()

	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
