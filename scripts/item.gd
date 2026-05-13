extends Area2D

@export var item_name: String = ""
@export var room_name: String = ""
var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var _run_active: bool = true
var _home_sprite_scale: Vector2 = Vector2.ONE
var _home_sprite_scale_known: bool = false
var _original_transform: Transform2D

func _ready():
	input_pickable = true
	_original_transform = transform
	call_deferred("_ensure_spawn_registered")
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _ensure_spawn_registered() -> void:
	if is_in_group("items"):
		return
	finish_kitchen_spawn_setup()

func set_run_active(on: bool) -> void:
	_run_active = on
	if on:
		visible = true
		input_pickable = true
		monitoring = true
		monitorable = true
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		visible = false
		input_pickable = false
		monitoring = false
		monitorable = false
		process_mode = Node.PROCESS_MODE_DISABLED
		dragging = false
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)

func finish_kitchen_spawn_setup() -> void:
	if not _run_active:
		return
	if InventoryManager.is_permanently_removed(item_name):
		queue_free()
		return
	add_to_group("items")
	InventoryManager.register_item(item_name, transform)
	var sp0 := _get_sprite()
	if sp0:
		_home_sprite_scale = sp0.scale
		_home_sprite_scale_known = true

func _get_sprite() -> Node2D:
	for child in get_children():
		if child is Sprite2D or child is TextureRect:
			return child
	return null

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not dragging:
				_start_drag()

func _start_drag():
	if not _run_active:
		return
	if item_name == "" or room_name == "":
		push_error("Set item_name and room_name in Inspector on: " + name)
		return
	dragging = true
	drag_offset = get_global_mouse_position() - global_position
	z_index = 100
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_DRAG)
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

func _stop_drag():
	dragging = false
	z_index = 10
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
	for zone in get_tree().get_nodes_in_group("drop_zone"):
		zone.hide_zone()
	await get_tree().physics_frame
	var hit_zone = null
	for zone in get_tree().get_nodes_in_group("drop_zone"):
		if overlaps_area(zone):
			hit_zone = zone
			break
	if hit_zone:
		var sprite = _get_sprite()
		var tex = sprite.texture if sprite else null
		var success = InventoryManager.add_item(item_name, room_name, tex)
		if success:
			var inventory_ui = get_tree().get_first_node_in_group("inventory_ui")
			if inventory_ui:
				inventory_ui.refresh()
			visible = false
			print("Placed ", item_name, " into inventory!")
		else:
			_snap_back()
	else:
		_snap_back()

func _apply_spawn_local() -> void:
	transform = _original_transform
	if _home_sprite_scale_known:
		var sp := _get_sprite()
		if sp:
			sp.scale = _home_sprite_scale

func restore_from_inventory_pickup() -> void:
	if not _run_active:
		return
	visible = true
	_apply_spawn_local()

func _snap_back():
	_apply_spawn_local()
	print("Missed or rejected, snapping back")

func _on_mouse_entered():
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_DRAG)

func _on_mouse_exited():
	if not dragging:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
