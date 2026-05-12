extends Control

@onready var transition_player = $Transition/Transitions/AnimationPlayer
@onready var overlay = $Transition/Transitions/ColorRect

# The lock to prevent clicking while transitioning
var is_transitioning = false

func _ready():
	# When entering the kitchen, immediately fade in from black
	$DoortoCorridor.pressed.connect(_on_corridor_door_pressed)
	transition_player.play("black_to_fade")
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	await transition_player.animation_finished
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_corridor_door_pressed():
	# If we are already mid-fade, don't do anything
	if is_transitioning:
		return
		
	# Start the transition process
	enter_corridor()

func enter_corridor():
	is_transitioning = true
	
	# 1. Block the mouse so they can't click again
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 2. Play the fade to black (Ensure you have a "fade_to_black" animation)
	# If your animation is named differently, change this string:
	transition_player.play_backwards("black_to_fade") 
	
	# 3. Wait for it to finish
	await transition_player.animation_finished
	
	# 4. Change the scene
	get_tree().change_scene_to_file("res://scenes/corridor.tscn")
