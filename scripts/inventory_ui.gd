# inventory_ui.gd
extends CanvasLayer

@onready var slots = [
	$InventoryBar/Slot1,
	$InventoryBar/Slot2,
	$InventoryBar/Slot3
]

var item_textures = {
	"dead-flower": preload("res://assets/sprites/items/dead_flower.jpg"),
	"poison-ivy": preload("res://assets/sprites/items/poison_ivy.jpg"),
	"surgical-mask": preload("res://assets/sprites/items/mask.jpg"),
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

# Drag state
var dragging_item: String = ""
var dragging_from_slot: int = -1
var ghost: TextureRect = null

func _ready():
	add_to_group("inventory_ui")
	# Flip slots right-side-up (parent has negative Y scale)
	for slot in slots:
		slot.flip_v = true
	refresh()
	for i in range(slots.size()):
		slots[i].gui_input.connect(_on_slot_input.bind(i))

func refresh():
	for i in range(slots.size()):
		var item = InventoryManager.slots[i]["item"]
		if item != "":
			slots[i].texture = item_textures.get(item, slot_empty_texture)
		else:
			slots[i].texture = slot_empty_texture

# --- Slot input: start drag ---
func _on_slot_input(event: InputEvent, slot_index: int):
	if not (event is InputEventMouseButton):
		return
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var item_name = InventoryManager.slots[slot_index]["item"]
		if item_name == "":
			return
		_start_slot_drag(item_name, slot_index)

func _start_slot_drag(item_name: String, slot_index: int):
	dragging_item = item_name
	dragging_from_slot = slot_index

	# Create a ghost icon that follows the mouse
	ghost = TextureRect.new()
	ghost.texture = item_textures.get(item_name, slot_empty_texture)
	ghost.custom_minimum_size = Vector2(80, 80)
	ghost.size = Vector2(80, 80)
	ghost.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ghost.z_index = 200
	# Anchor ghost to screen coordinates via a plain Control overlay
	var overlay = get_node_or_null("DragOverlay")
	if overlay == null:
		overlay = Control.new()
		overlay.name = "DragOverlay"
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(overlay)
	overlay.add_child(ghost)
	_update_ghost_position()

func _update_ghost_position():
	if ghost == null:
		return
	var mp = ghost.get_viewport().get_mouse_position()
	ghost.position = mp - Vector2(40, 40)

func _process(_delta):
	if dragging_item != "":
		_update_ghost_position()

func _input(event: InputEvent):
	if dragging_item == "":
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_stop_slot_drag()

func _stop_slot_drag():
	var item_to_submit = dragging_item
	dragging_item = ""
	dragging_from_slot = -1

	# Clean up ghost
	if ghost:
		ghost.queue_free()
		ghost = null

	# Check if mouse is over a submission_zone Area2D
	var submitted = false
	var space_state = get_viewport().world_2d.direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_viewport().get_mouse_position()
	query.collide_with_areas = true
	var results = space_state.intersect_point(query)
	for result in results:
		if result.collider.is_in_group("submission_zone"):
			submitted = true
			break

	if submitted:
		# Tell the corridor to check it
		var corridor = get_tree().current_scene
		if corridor.has_method("check_submission"):
			corridor.check_submission(item_to_submit)
	# If not over submission zone, do nothing — item stays in inventory
