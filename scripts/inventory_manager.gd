extends Node

var slots: Array[Dictionary] = [
	{"item": "", "room": "", "texture": null},
	{"item": "", "room": "", "texture": null},
	{"item": "", "room": "", "texture": null},
]

var picked_up_items: Dictionary = {}
var item_spawn_transforms: Dictionary = {}
var kitchen_layout_variant_by_prefix: Dictionary = {}
var toilet_layout_variant_by_prefix: Dictionary = {}

# Items correctly submitted to the prompt — never respawn
var permanently_removed: Array = []

func get_or_roll_kitchen_variant(prefix: String, variant_count: int) -> int:
	if variant_count <= 0:
		return 0
	if not kitchen_layout_variant_by_prefix.has(prefix):
		kitchen_layout_variant_by_prefix[prefix] = randi() % variant_count
	var stored: int = int(kitchen_layout_variant_by_prefix[prefix])
	return stored % variant_count

func reset_kitchen_layout_for_new_game() -> void:
	kitchen_layout_variant_by_prefix.clear()

func get_or_roll_toilet_variant(prefix: String, variant_count: int) -> int:
	if variant_count <= 0:
		return 0
	if not toilet_layout_variant_by_prefix.has(prefix):
		toilet_layout_variant_by_prefix[prefix] = randi() % variant_count
	var stored: int = int(toilet_layout_variant_by_prefix[prefix])
	return stored % variant_count

func reset_toilet_layout_for_new_game() -> void:
	toilet_layout_variant_by_prefix.clear()

func register_item(item_name: String, local_xf: Transform2D) -> void:
	item_spawn_transforms[item_name] = local_xf

func add_item(item_name: String, room_name: String, texture: Texture2D = null) -> bool:
	if has_item(item_name):
		return false
	# Block permanently removed items from re-entering inventory
	if item_name in permanently_removed:
		return false
	for i in range(slots.size()):
		if slots[i]["item"] == "":
			slots[i]["item"] = item_name
			slots[i]["room"] = room_name
			slots[i]["texture"] = texture
			if not picked_up_items.has(room_name):
				picked_up_items[room_name] = []
			if item_name not in picked_up_items[room_name]:
				picked_up_items[room_name].append(item_name)
			print(item_name, " added to inventory")
			return true
	print("Inventory full")
	return false

func remove_item(item_name: String):
	for i in range(slots.size()):
		if slots[i]["item"] == item_name:
			var room_name = slots[i]["room"]
			slots[i]["item"] = ""
			slots[i]["room"] = ""
			slots[i]["texture"] = null
			if picked_up_items.has(room_name):
				picked_up_items[room_name].erase(item_name)
				if picked_up_items[room_name].is_empty():
					picked_up_items.erase(room_name)
			print(item_name, " removed from inventory")
			return

func permanently_remove_item(item_name: String) -> void:
	remove_item(item_name)
	if item_name not in permanently_removed:
		permanently_removed.append(item_name)
	print(item_name, " permanently removed")

func is_permanently_removed(item_name: String) -> bool:
	return item_name in permanently_removed

func has_item(item_name: String) -> bool:
	for slot in slots:
		if slot["item"] == item_name:
			return true
	return false

func is_picked_up(item_name: String, room_name: String) -> bool:
	if picked_up_items.has(room_name):
		return item_name in picked_up_items[room_name]
	return false

func get_spawn_transform(item_name: String) -> Transform2D:
	return item_spawn_transforms.get(item_name, Transform2D())

func get_spawn_position(item_name: String) -> Vector2:
	return get_spawn_transform(item_name).origin

func get_item_room(item_name: String) -> String:
	for slot in slots:
		if slot["item"] == item_name:
			return slot["room"]
	return ""

func clear_inventory():
	for i in range(slots.size()):
		slots[i]["item"] = ""
		slots[i]["room"] = ""
		slots[i]["texture"] = null
	picked_up_items.clear()
	permanently_removed.clear()
	print("Inventory cleared")
