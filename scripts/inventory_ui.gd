extends CanvasLayer

@onready var slots = [
	$InventoryBar/Slot1,
	$InventoryBar/Slot2,
	$InventoryBar/Slot3
]

var item_textures = {
	"dead-flower": preload("res://assets/sprites/items/dead_flower.jpg"),
	"poison-ivy":    preload("res://assets/sprites/items/poison_ivy.jpg"),
	"surgical-mask":      preload("res://assets/sprites/items/mask.jpg"),
	"dead-rat": preload("res://assets/sprites/items/dead_rat.jpg"),
	"clock": preload("res://assets/sprites/items/clock.jpg"),
	"blade": preload("res://assets/sprites/items/rusted_saw_blade.jpg"),
	"knife": preload("res://assets/sprites/items/knife.jpg"),
	"wine-bottle": preload("res://assets/sprites/items/broken_wine_bottle.jpg"),
	"hankerchief": preload("res://assets/sprites/items/hankerchief.jpg"),
	"envelope": preload("res://assets/sprites/items/burnt_envelope.jpg"),
	"medicine": preload("res://assets/sprites/items/medicine.jpg"),
	"poison-vial": preload("res://assets/sprites/items/poison_vial.jpg"),
	"mirror": preload("res://assets/sprites/items/mirror.jpg"),
	"scream-painting": preload("res://assets/sprites/items/scream_painting.jpg"),
}

var slot_empty_texture = preload("res://assets/sprites/inventory-slot.png")
var current_room: String = ""

func _ready():
	add_to_group("inventory_ui")
	refresh()
	for i in range(slots.size()):
		slots[i].gui_input.connect(_on_slot_clicked.bind(i))

func refresh():
	for i in range(slots.size()):
		var item = InventoryManager.slots[i]["item"]
		if item != "":
			slots[i].texture = item_textures.get(item, slot_empty_texture)
		else:
			slots[i].texture = slot_empty_texture

func _on_slot_clicked(event: InputEvent, slot_index: int):
	if not (event is InputEventMouseButton):
		return
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var item_name = InventoryManager.slots[slot_index]["item"]
		var item_room  = InventoryManager.slots[slot_index]["room"]

		if item_name == "":
			return

		if current_room == item_room:
			InventoryManager.remove_item(item_name)
			refresh()
			var item_node = null
			for node in get_tree().get_nodes_in_group("items"):
				if node.item_name == item_name:
					item_node = node
					break
			if item_node:
				item_node.global_position = InventoryManager.get_spawn_position(item_name)
				item_node.visible = true
			print("Returned ", item_name, " to its original spot")
		else:
			print("Can't return here! ", item_name, " belongs in: ", item_room)
