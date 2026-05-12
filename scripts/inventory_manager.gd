extends Node

var slots: Array[String] = ["", "", ""]

func add_item(item_name: String) -> bool:
	for i in range(slots.size()):
		if slots[i] == "":
			slots[i] = item_name
			return true
	return false

func remove_item(item_name: String):
	for i in range(slots.size()):
		if slots[i] == item_name:
			slots[i] = ""
			return
