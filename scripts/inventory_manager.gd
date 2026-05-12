extends Node

var slots: Array[Dictionary] = [
	{"item": "", "room": ""},
	{"item": "", "room": ""},
	{"item": "", "room": ""}
]

# Tracks items currently stored in inventory
var picked_up_items: Dictionary = {}

# Local transform (relative to parent) when the item first settled — NOT global_transform.
# Node2D under Control can round-trip global_transform incorrectly; local keeps instance scale.
var item_spawn_transforms: Dictionary = {}

func register_item(item_name: String, local_xf: Transform2D) -> void:
	# Only the active kitchen copy registers; overwrite when re-entering the scene.
	item_spawn_transforms[item_name] = local_xf

func add_item(item_name: String, room_name: String) -> bool:

	# Prevent duplicates
	if has_item(item_name):
		return false

	for i in range(slots.size()):

		if slots[i]["item"] == "":

			slots[i]["item"] = item_name
			slots[i]["room"] = room_name

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

			if picked_up_items.has(room_name):

				picked_up_items[room_name].erase(item_name)

				# Clean empty room arrays
				if picked_up_items[room_name].is_empty():
					picked_up_items.erase(room_name)

			print(item_name, " removed from inventory")

			return

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
	# Local-space origin; use only if parent transform is identity at spawn.
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

	picked_up_items.clear()

	print("Inventory cleared")
