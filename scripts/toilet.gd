extends Control

@onready var transition_player = $Transition/Transitions/AnimationPlayer
@onready var overlay = $Transition/Transitions/ColorRect

# The lock to prevent clicking while transitioning
var is_transitioning = false

func _ready():
	$door.pressed.connect(_on_door_pressed)

	for item in $Item.get_children():
		item.add_to_group("items")
		if InventoryManager.is_picked_up(item.item_name, "toilet"):
			item.visible = false
			
	transition_player.play("black_to_fade")
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	await transition_player.animation_finished
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Inventory.current_room = "toilet"

func _on_door_pressed():
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	transition_player.play("fade_to_black")
	await transition_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/corridor.tscn")
