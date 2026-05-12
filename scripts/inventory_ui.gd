extends CanvasLayer

@onready var slots = [
	$InventoryBar/Slot1,
	$InventoryBar/Slot2,
	$InventoryBar/Slot3
]

func _ready():
	refresh()

func refresh():
	for i in range(slots.size()):
		var item = InventoryManager.slots[i]
		# future: swap texture or show item icon here
