# global_background.gd
extends Node2D

var current_bg_path1: String = "res://assets/sprites/kitchen/BLUE.png"
var current_bg_path2: String = "res://assets/sprites/kitchen/BLUE.png"
var doors_locked: bool = false

var items_to_restore: Array = []

const PROMPTS = [
	{
		"text": "BRING ME WHAT NO LONGER LIVES",
		"answer": "dead-flower",
		"bg1": "res://assets/sprites/kitchen/BLUE.png",
		"bg2": "res://assets/sprites/kitchen/BLUE.png"
	},
	{
		"text": "BRING ME THE FACE YOU HIDE BEHIND",
		"answer": "surgical-mask",
		"bg1": "res://assets/sprites/kitchen/VIOLET.png",
		"bg2": "res://assets/sprites/kitchen/VIOLET.png"
	},
	{
		"text": "BRING ME WHAT KEEPS WATCHING",
		"answer": "clock",
		"bg1": "res://assets/sprites/kitchen/RED.png",
		"bg2": "res://assets/sprites/kitchen/RED.png"
	},
	{
		"text": "BRING ME WHAT ENDS THINGS",
		"answer": "knife",
		"bg1": "res://assets/sprites/kitchen/RED.png",
		"bg2": "res://assets/sprites/kitchen/RED.png"
	},
	{
		"text": "BRING ME THE STAIN THAT REFUSES TO HIDE GUILT",
		"answer": "bloody-handkerchief",
		"bg1": "res://assets/sprites/kitchen/RED.png",
		"bg2": "res://assets/sprites/kitchen/RED.png"
	},
	{
		"text": "BRING ME WHAT LETS YOU FORGET THE PAIN",
		"answer": "medicine",
		"bg1": "res://assets/sprites/kitchen/BLUE.png",
		"bg2": "res://assets/sprites/kitchen/BLUE.png"
	},
	{
		"text": "BRING ME THE ONE THAT LIES TO YOU",
		"answer": "mirror",
		"bg1": "res://assets/sprites/kitchen/VIOLET.png",
		"bg2": "res://assets/sprites/kitchen/VIOLET.png"
	}
]

var remaining_prompt_indices: Array = []
var current_prompt_data: Dictionary = {}

func reset_prompts() -> void:
	remaining_prompt_indices = range(PROMPTS.size())
	remaining_prompt_indices.shuffle()
	current_prompt_data = {}
	items_to_restore.clear()  

func pick_new_prompt() -> bool:
	if remaining_prompt_indices.is_empty():
		return false
	var idx = remaining_prompt_indices.pop_front()
	current_prompt_data = PROMPTS[idx]
	current_bg_path1 = current_prompt_data["bg1"]
	current_bg_path2 = current_prompt_data["bg2"]
	return true

func prompts_remaining() -> int:
	return remaining_prompt_indices.size()

func mark_item_for_restoration(item_name: String) -> void:
	"""Mark an item to be restored when its room is loaded"""
	if item_name not in items_to_restore:
		items_to_restore.append(item_name)
		print("Marked for restoration: ", item_name)

func restore_items_for_room(room_name: String) -> void:
	"""Restore any items that belong to this room"""
	var items_to_remove: Array = []
	
	for item_name in items_to_restore:
		# Get the room this item belongs to
		var item_room = _get_item_room(item_name)
		
		if item_room == room_name:
			# Find the item node in the current scene
			for node in get_tree().get_nodes_in_group("items"):
				if node.get("item_name") == item_name and node.get("room_name") == room_name:
					node.visible = true
					node.set_process_input(true)
					node.input_pickable = true
					
					if node.has_method("restore_from_inventory_pickup"):
						node.restore_from_inventory_pickup()
					
					if node.has_method("set_run_active"):
						node.set_run_active(true)
					
					items_to_remove.append(item_name)
					print("Restored item on scene load: ", item_name, " to ", room_name)
					break
	
	# Remove restored items from the list
	for item in items_to_remove:
		items_to_restore.erase(item)

func _get_item_room(item_name: String) -> String:
	"""Determine which room an item belongs to"""
	# Check if it's a prompt answer item (corridor)
	for prompt in PROMPTS:
		if prompt["answer"] == item_name:
			return "corridor"
	
	# ADD YOUR ACTUAL TOILET ITEM NAMES HERE
	var toilet_items = ["bloody-handkerchief", "envelope", "medicine", "poison-vial", 
						"mirror", "scream-painting"]  
	
	if item_name in toilet_items:
		return "toilet"
	
	# Kitchen items
	var kitchen_items = ["knife", "blade", "clock", "dead-flower", "dead-rat", 
						 "surgical-mask", "poison-ivy", "wine-bottle", "medicine", 
						 "mirror", "bloody-handkerchief"]
	if item_name in kitchen_items:
		return "kitchen"
	
	# Default to kitchen
	return "kitchen"
