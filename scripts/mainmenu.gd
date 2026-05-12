extends Node2D

func _ready():
	# Connect the buttons to their functions
	$Menu/Button2.pressed.connect(_on_start_pressed)
	$Menu/Button.pressed.connect(_on_quit_pressed)
	# Optional: connect Credits button too
	$Menu/Button3.pressed.connect(_on_credits_pressed)

func _on_start_pressed():
	randomize()
	InventoryManager.reset_kitchen_layout_for_new_game()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_credits_pressed():
	print("Credits button pressed!")  # Add your credits logic here
