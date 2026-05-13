extends Area2D

@onready var transition_player = get_node("../Transition/Transitions/AnimationPlayer")
@onready var overlay1 = get_node("../Transition/Transitions/ColorRect")
@onready var overlay2 = get_node("../Transition/Transitions/TextureRect")

var is_transitioning = false

func _input(event):
	if is_transitioning:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var poly = $DoorToCorridor
		if Geometry2D.is_point_in_polygon(get_local_mouse_position(), poly.polygon):
			enter_room("res://scenes/corridor.tscn")

func enter_room(scene_path):
	is_transitioning = true
	overlay1.mouse_filter = Control.MOUSE_FILTER_STOP
	if has_node("/root/AudioManager"):  # ✅ safe check
		AudioManager.play_sfx()  # replace some_sound with your actual sound
	transition_player.play("fade_to_black")
	await transition_player.animation_finished
	get_tree().change_scene_to_file(scene_path)
