extends Area2D

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Door clicked!")
			on_door_pressed()

func on_door_pressed():
	get_tree().change_scene_to_file("res://scenes/kitchen.tscn")
