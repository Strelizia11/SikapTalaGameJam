extends Control

func _ready():
	$door.pressed.connect(_on_door_pressed)
	$Inventory.current_room = "toilet"

	for item in $Item.get_children():
		item.add_to_group("items")
		if InventoryManager.is_picked_up(item.item_name, "toilet"):
			item.visible = false

func _on_door_pressed():
	get_tree().change_scene_to_file("res://scenes/corridor.tscn")
