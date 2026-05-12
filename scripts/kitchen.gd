extends Control

@onready var transition_player = $Transition/Transitions/AnimationPlayer
@onready var overlay = $Transition/Transitions/ColorRect

# The lock to prevent clicking while transitioning
var is_transitioning = false

func _ready():
	var kitchen_items = ["knife", "blade", "clock", "dead-flower", "dead-rat", "mask", "poison-ivy", "wine-bottle"]
	for item_node in get_children():
		if item_node.has_method("_start_drag"):
			if InventoryManager.is_picked_up(item_node.item_name, "kitchen"):
				item_node.visible = false

	transition_player.play("black_to_fade")
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	await transition_player.animation_finished
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Inventory.current_room = "kitchen"
