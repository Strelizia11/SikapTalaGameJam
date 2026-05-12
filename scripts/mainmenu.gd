extends Node2D

func _ready():
	# Connect the buttons to their functions
	$Menu/VBoxContainer/Button2.pressed.connect(_on_start_pressed)
	$Menu/VBoxContainer/Button.pressed.connect(_on_quit_pressed)
	# Optional: connect Credits button too
	$Menu/VBoxContainer/Button3.pressed.connect(_on_credits_pressed)

func _on_start_pressed():
	# Change this path to your actual game scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_credits_pressed():
	print("Credits button pressed!")  # Add your credits logic here
