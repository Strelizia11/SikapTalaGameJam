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
	"bloody-handkerchief": preload("res://assets/sprites/items/silhouette/s-handkerchief_0.png"),
	"envelope": preload("res://assets/sprites/items/silhouette/s-envelop_0.png"),
	"medicine": preload("res://assets/sprites/items/silhouette/s-medicine_0.png"),
	"poison-vial": preload("res://assets/sprites/items/silhouette/s-poison_0.png"),
	"mirror": preload("res://assets/sprites/items/silhouette/s-mirror_1.png"),
	"scream-painting": preload("res://assets/sprites/items/silhouette/s-painting_1.png"),
}

var slot_empty_texture = preload("res://assets/sprites/inventory-slot.png")
var current_room: String = ""

## Logical slot size (layout space). Textures are scaled to fill this rect exactly.
const SLOT_ICON_SIZE := Vector2(1500, 1500)

# Drag state
var dragging_item: String = ""
var dragging_from_slot: int = -1
var ghost: TextureRect = null
var drag_start_screen_pos: Vector2 = Vector2.ZERO

## If the pointer barely moves before release, treat it as a click: return the item to its room.
const CLICK_RETURN_MAX_DISTANCE_PX: float = 24.0
## InventoryBar uses negative scale; get_global_rect().size can blow up — cap drag ghost size.
const GHOST_ICON_MAX_PX: float = 512.0

func _ready():
	add_to_group("inventory_ui")
	# Flip slots right-side-up (parent has negative Y scale)
	for slot in slots:
		slot.flip_v = true
		# Without EXPAND_IGNORE_SIZE, TextureRect uses the texture's pixel size as minimum → huge slots.
		slot.custom_minimum_size = SLOT_ICON_SIZE
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot.stretch_mode = TextureRect.STRETCH_SCALE
		slot.clip_contents = true
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
	drag_start_screen_pos = get_viewport().get_mouse_position()

	# Match ghost to the slot's on-screen size; abs + clamp avoids huge rects from flipped/scaled UI.
	var r: Rect2 = slots[slot_index].get_global_rect()
	var slot_px: Vector2 = Vector2(absf(r.size.x), absf(r.size.y))
	slot_px.x = clampf(slot_px.x, 1.0, GHOST_ICON_MAX_PX)
	slot_px.y = clampf(slot_px.y, 1.0, GHOST_ICON_MAX_PX)

	# Create a ghost icon that follows the mouse
	ghost = TextureRect.new()
	ghost.texture = item_textures.get(item_name, slot_empty_texture)
	ghost.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ghost.custom_minimum_size = slot_px
	ghost.size = slot_px
	ghost.stretch_mode = TextureRect.STRETCH_SCALE
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
	ghost.position = mp - ghost.size * 0.5

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
	var drag_start = drag_start_screen_pos
	dragging_item = ""
	dragging_from_slot = -1

	if ghost:
		ghost.queue_free()
		ghost = null

	var space_state = get_viewport().world_2d.direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_viewport().get_mouse_position()
	query.collide_with_areas = true
	var results = space_state.intersect_point(query)

	var submitted = false
	for result in results:
		if result.collider.is_in_group("submission_zone"):
			submitted = true
			break

	if submitted:
		var corridor = get_tree().current_scene
		if corridor.has_method("check_submission"):
			var correct = corridor.check_submission(item_to_submit)
			if correct:
				# Mark permanently gone in data
				InventoryManager.permanently_remove_item(item_to_submit)
				# Find and destroy the actual node in the scene tree right now
				for node in get_tree().get_nodes_in_group("items"):
					if node.get("item_name") == item_to_submit:
						node.queue_free()
			else:
				# Wrong — remove from inventory and put it back in the world
				InventoryManager.remove_item(item_to_submit)
				_restore_item_to_world(item_to_submit)
		refresh()
	elif item_to_submit != "" and drag_start.distance_to(query.position) <= CLICK_RETURN_MAX_DISTANCE_PX:
		_restore_item_to_world(item_to_submit)


func _restore_item_to_world(item_name: String) -> void:
	var room_name: String = InventoryManager.get_item_room(item_name)
	InventoryManager.remove_item(item_name)
	refresh()
	for node in get_tree().get_nodes_in_group("items"):
		if not (node is Area2D):
			continue
		if node.get("item_name") != item_name:
			continue
		if room_name != "" and node.get("room_name") != room_name:
			continue
		if node.has_method("restore_from_inventory_pickup"):
			node.restore_from_inventory_pickup()
		else:
			node.visible = true
			node.transform = InventoryManager.get_spawn_transform(item_name)
		break
