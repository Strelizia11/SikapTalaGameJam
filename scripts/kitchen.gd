extends Control

func _ready():
	$DoortoCorridor.pressed.connect(_on_corridor_door_pressed)

func _on_corridor_door_pressed():
	get_tree().change_scene_to_file("res://scenes/corridor.tscn")
