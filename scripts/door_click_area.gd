extends Area2D

@onready var transition_player = get_node("../Transition/Transitions/AnimationPlayer")
@onready var overlay = get_node("../Transition/Transitions/ColorRect")

var is_transitioning = false

func _input(event):
	if is_transitioning:
		return
	if GlobalBackground.doors_locked:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var poly1 = $KitchenDoorEntry
		var poly2 = $ToiletDoorEntry
		if Geometry2D.is_point_in_polygon(get_local_mouse_position(), poly1.polygon):
			enter_room("res://scenes/kitchen.tscn")
		elif Geometry2D.is_point_in_polygon(get_local_mouse_position(), poly2.polygon):
			enter_room("res://scenes/toilet.tscn")

func enter_room(scene_path):
	is_transitioning = true
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	if has_node("/root/AudioManager"):  # ✅ won't crash if AudioManager is missing
		AudioManager.play_sfx(preload("res://assets/sound/Door_sfx.wav"))
	transition_player.play("fade_to_black")
	await transition_player.animation_finished
	get_tree().change_scene_to_file(scene_path)
