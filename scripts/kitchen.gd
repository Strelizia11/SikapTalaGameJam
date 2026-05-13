extends Control

@onready var transition_player = $Transition/Transitions/AnimationPlayer
@onready var overlay1 = $Transition/Transitions/ColorRect
@onready var overlay2 = $Transition/Transitions/TextureRect

# The lock to prevent clicking while transitioning
var is_transitioning = false

## Scene node name prefix for each pickup; expects `{Prefix}_0`, `{Prefix}_1`, `{Prefix}_2` (optional — single node without suffix still works).
const ITEM_SPAWN_PREFIXES: Array[String] = [
	"Knife", "Blade", "Clock", "DeadFlower", "DeadRat", "Mask", "PoisonIvy", "WineBottle"
]


func _activate_one_random_variant_per_item() -> void:
	for prefix in ITEM_SPAWN_PREFIXES:
		var variants: Array[Node] = []
		for i in 3:
			var n := get_node_or_null("%s_%d" % [prefix, i])
			if n != null:
				variants.append(n)
		if variants.is_empty():
			continue
		var keep_i := InventoryManager.get_or_roll_kitchen_variant(prefix, variants.size())
		for j in range(variants.size()):
			var node: Node = variants[j]
			var on := j == keep_i
			if node.has_method("set_run_active"):
				node.set_run_active(on)


func _register_all_item_spawn_data() -> void:
	for child in get_children():
		if child.has_method("finish_kitchen_spawn_setup"):
			child.finish_kitchen_spawn_setup()


func _ready():
	_activate_one_random_variant_per_item()
	_register_all_item_spawn_data()
	
	if GlobalBackground.has_method("restore_items_for_room"):
		GlobalBackground.restore_items_for_room("kitchen")

	var kitchen_items = ["knife", "blade", "clock", "dead-flower", "dead-rat", "mask", "poison-ivy", "wine-bottle"]
	for item_node in get_children():
		if item_node.has_method("_start_drag"):
			if InventoryManager.is_picked_up(item_node.item_name, "kitchen"):
				item_node.visible = false

	transition_player.play("black_to_fade")
	overlay1.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay2.mouse_filter = Control.MOUSE_FILTER_STOP
	await transition_player.animation_finished
	overlay1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Inventory.current_room = "kitchen"
