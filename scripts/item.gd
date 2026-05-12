extends Area2D

## Required setup in the Inspector
@export var item_name: String = ""
@export var room_name: String = ""

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready():
	input_pickable = true
	add_to_group("items")

	var sprite = _get_sprite()
	if sprite:
		var world_pos = sprite.global_position
		global_position = world_pos
		sprite.position = Vector2.ZERO

		# Remap collision polygon from world space to local space
		# (subtract the world_pos we just moved the Area2D to)
		for child in get_children():
			if child is CollisionPolygon2D:
				var new_poly: PackedVector2Array = []
				for pt in child.polygon:
					new_poly.append(pt - world_pos)  # critical: convert to local space
				child.polygon = new_poly
				child.position = Vector2.ZERO
			elif child is CollisionShape2D:
				child.position = Vector2.ZERO

	InventoryManager.register_item(item_name, global_position)

func _get_sprite() -> Node2D:
	for child in get_children():
		if child is Sprite2D or child is TextureRect:
			return child
	return null

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not dragging:
			print("Mouse event detected on: ", name)
			_start_drag()

func _start_drag():
	if item_name == "" or room_name == "":
		push_error("Set item_name and room_name in Inspector on: " + name)
		return

	dragging = true
	drag_offset = get_global_mouse_position() - global_position
	z_index = 100

	for zone in get_tree().get_nodes_in_group("drop_zone"):
		if zone.has_method("show_zone"):
			zone.show_zone()

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() - drag_offset

func _input(event):
	if dragging and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_stop_drag()

func _get_hovered_drop_zone():
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	var results = space_state.intersect_point(query)
	for result in results:
		var collider = result.collider
		if collider.is_in_group("drop_zone"):
			return collider
	return null

func _stop_drag():
	dragging = false
	z_index = 0

	for zone in get_tree().get_nodes_in_group("drop_zone"):
		if zone.has_method("hide_zone"):
			zone.hide_zone()

	var dropped_zone = _get_hovered_drop_zone()
	if dropped_zone:
		var success = InventoryManager.add_item(item_name, room_name)
		if success:
			var inventory_ui = get_tree().get_first_node_in_group("inventory_ui")
			if inventory_ui:
				inventory_ui.refresh()
			visible = false  
			print("Placed ", item_name, " into inventory!")
		else:
			_return_to_start()
	else:
		_return_to_start()

func _return_to_start():
	print("Missed or full, snapping back")
	global_position = InventoryManager.get_spawn_position(item_name)
