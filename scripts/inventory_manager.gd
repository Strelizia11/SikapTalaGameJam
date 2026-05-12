extends Node

var slots: Array[Dictionary] = [
	{"item": "", "room": ""},
	{"item": "", "room": ""},
	{"item": "", "room": ""}
]

var picked_up_items: Dictionary = {}

var item_spawn_positions: Dictionary = {}

func register_item(item_name: String, position: Vector2):
	if not item_spawn_positions.has(item_name):
		item_spawn_positions[item_name] = position

func add_item(item_name: String, room_name: String) -> bool:
	for i in range(slots.size()):
		if slots[i]["item"] == "":
			slots[i]["item"] = item_name
			slots[i]["room"] = room_name
			if not picked_up_items.has(room_name):
				picked_up_items[room_name] = []
			if not item_name in picked_up_items[room_name]:
				picked_up_items[room_name].append(item_name)
			print("Added: ", item_name, " from: ", room_name)
			return true
	print("Inventory full!")
	return false

func remove_item(item_name: String):
	for i in range(slots.size()):
		if slots[i]["item"] == item_name:
			var room_name = slots[i]["room"]
			slots[i]["item"] = ""
			slots[i]["room"] = ""
			if picked_up_items.has(room_name):
				picked_up_items[room_name].erase(item_name)
			print("Removed: ", item_name)
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

func get_spawn_position(item_name: String) -> Vector2:
	return item_spawn_positions.get(item_name, Vector2.ZERO)

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
