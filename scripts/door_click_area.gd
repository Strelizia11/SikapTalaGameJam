extends Area2D

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# This checks if the mouse is actually over your polygon
		# 'get_node("KitchenDoorEntry")' is your CollisionPolygon2D
		var poly1 = $KitchenDoorEntry 
		var poly2 = $ToiletDoorEntry 
		if Geometry2D.is_point_in_polygon(get_local_mouse_position(), poly1.polygon):
			enter_kitchen()
		elif Geometry2D.is_point_in_polygon(get_local_mouse_position(), poly2.polygon):
			enter_toilet()

func enter_kitchen():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/kitchen.tscn")
	
func enter_toilet():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/toilet.tscn")
