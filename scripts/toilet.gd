extends Control

func _ready():
	$door.pressed.connect(_on_door_pressed)

func _on_door_pressed():
	get_tree().change_scene_to_file("res://scenes/corridor.tscn")
