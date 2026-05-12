extends Control

@onready var transition_player = $Transition/Transitions/AnimationPlayer

func _ready():
	transition_player.play("black_to_fade")
	$DoortoCorridor.pressed.connect(_on_corridor_door_pressed)

func _on_corridor_door_pressed():
	get_tree().change_scene_to_file("res://scenes/corridor.tscn")

func fade_out():
	transition_player.play("black_to_fade")
