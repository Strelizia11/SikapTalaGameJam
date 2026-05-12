extends Area2D

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# This checks if the mouse is actually over your polygon
		# 'get_node("KitchenDoorEntry")' is your CollisionPolygon2D
		var poly = $KitchenDoorEntry 
		if Geometry2D.is_point_in_polygon(get_local_mouse_position(), poly.polygon):
			print("Kitchen door clicked (via global input)!")
			enter_kitchen()

func enter_kitchen():
	print("Attempting to switch...")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/kitchen.tscn")
