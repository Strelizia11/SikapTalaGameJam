extends Node2D

@onready var transition_player = $Transition/Transitions/AnimationPlayer
@onready var overlay1 = $Transition/Transitions/ColorRect
@onready var overlay2 = $Transition/Transitions/TextureRect

func _ready():
	
	$Menu/START.pressed.connect(_on_start_pressed)
	$Menu/QUIT.pressed.connect(_on_quit_pressed)
	$Menu/CREDITS.pressed.connect(_on_credits_pressed)
	
	transition_player.play("Trigger")
	overlay1.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay2.mouse_filter = Control.MOUSE_FILTER_STOP
	await transition_player.animation_finished
	
	overlay1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay2.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_start_pressed():
	randomize()
	InventoryManager.reset_kitchen_layout_for_new_game()
	InventoryManager.reset_toilet_layout_for_new_game()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_credits_pressed():
	print("Credits button pressed!")  # Add your credits logic here
