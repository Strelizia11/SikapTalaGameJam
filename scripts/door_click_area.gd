extends Area2D

# Make sure this path matches your AnimationPlayer's location
@onready var transition_player = get_node("../Transition/Transitions/AnimationPlayer")

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var poly1 = $KitchenDoorEntry
		var poly2 = $ToiletDoorEntry
		
		if Geometry2D.is_point_in_polygon(get_local_mouse_position(), poly1.polygon):
			enter_kitchen()
		elif Geometry2D.is_point_in_polygon(get_local_mouse_position(), poly2.polygon):
			enter_toilet()

func enter_kitchen():
	# 1. Play the fade out
	transition_player.play("fade_to_black")
	
	# 2. Wait for the animation to finish
	await transition_player.animation_finished
	
	# 3. Now change the scene
	get_tree().change_scene_to_file("res://scenes/kitchen.tscn")
	transition_player.play("black_to_fade")
	
func enter_toilet():
	transition_player.play("fade_to_black")
	await transition_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/toilet.tscn")
	transition_player.play("black_to_fade")
