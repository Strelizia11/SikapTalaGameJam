extends Area2D

@onready var transition_player = get_node("../Transition/Transitions/AnimationPlayer")
@onready var overlay = get_node("../Transition/Transitions/ColorRect")

# This variable prevents clicking while an animation is running
var is_transitioning = false

func _input(event):
	# If we are already transitioning, ignore all inputs!
	if is_transitioning:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var poly = $DoorToCorridor
		
		if Geometry2D.is_point_in_polygon(get_local_mouse_position(), poly.polygon):
			enter_room("res://scenes/corridor.tscn")

func enter_room(scene_path):
	# 1. Set the lock to TRUE
	is_transitioning = true
	
	# 2. Block mouse clicks via the overlay
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 3. Play the fade out
	transition_player.play("fade_to_black")
	await transition_player.animation_finished
	
	# 4. Change the scene
	get_tree().change_scene_to_file(scene_path)
