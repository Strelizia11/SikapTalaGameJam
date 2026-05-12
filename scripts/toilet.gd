extends Control

var dragging_node = null
var drag_offset = Vector2.ZERO
var starting_position = Vector2.ZERO 

func _ready():
	$door.pressed.connect(_on_door_pressed)
	
	# 2. Connect the "Handle" buttons
	$Item/handkerchief_img/handkerchief.button_down.connect(_on_drag_start.bind($Item/handkerchief_img))
	$Item/medicine_img/medicine.button_down.connect(_on_drag_start.bind($Item/medicine_img))
	$Item/mirror_img/mirror.button_down.connect(_on_drag_start.bind($Item/mirror_img))
	
	# 3. Connect the release signal
	$Item/handkerchief_img/handkerchief.button_up.connect(_on_drag_end)
	$Item/medicine_img/medicine.button_up.connect(_on_drag_end)
	$Item/mirror_img/mirror.button_up.connect(_on_drag_end)

func _process(_delta):
	if dragging_node:
		dragging_node.global_position = get_global_mouse_position() - drag_offset

func _on_drag_start(node_to_drag):
	dragging_node = node_to_drag
	starting_position = node_to_drag.global_position
	drag_offset = get_global_mouse_position() - node_to_drag.global_position

func _on_drag_end():
	if dragging_node:
		return_to_start()
		dragging_node = null

func return_to_start():
	dragging_node.global_position = starting_position

func _on_door_pressed():
	get_tree().change_scene_to_file("res://scenes/corridor.tscn")
