# corridor.gd
extends Control

@onready var prompt_text       = $Node2D/PromtWall
@onready var transition_player = $Transition/Transitions/AnimationPlayer

var feedback_timer: Timer
var input_blocked: bool = false  # NEW: Blocks user input during feedback

func _ready():
	transition_player.play("black_to_fade")
	$Inventory.current_room = "corridor"

	# NEW: Restore any items that belong to corridor
	if GlobalBackground.has_method("restore_items_for_room"):
		GlobalBackground.restore_items_for_room("corridor")

	# Also restore items that were dropped in the wrong room
	_restore_pending_items()

	feedback_timer = Timer.new()
	feedback_timer.one_shot  = true
	feedback_timer.wait_time = 1.5
	feedback_timer.timeout.connect(_on_feedback_timeout)
	add_child(feedback_timer)

	if GlobalBackground.current_prompt_data.is_empty():
		GlobalBackground.reset_prompts()
		GlobalBackground.pick_new_prompt()
	
	if has_node("/root/GameTimer") and not GameTimer._running:
		GameTimer.start_timer()

	display_current_riddle()

func _restore_pending_items():
	for node in get_tree().get_nodes_in_group("items"):
		if node.get("room_name") == "corridor":
			var item_name = node.get("item_name")
			# If this item is in inventory but should be restored
			if InventoryManager.has_item(item_name):
				# Check if it was dropped in wrong room
				var item_room = InventoryManager.get_item_room(item_name)
				if item_room != "corridor":
					# Restore it to corridor
					InventoryManager.remove_item(item_name)
					node.visible = true
					if node.has_method("restore_from_inventory_pickup"):
						node.restore_from_inventory_pickup()
					print("Restored misplaced item: ", item_name)

func display_current_riddle() -> void:
	prompt_text.text = GlobalBackground.current_prompt_data.get("text", "???")

func set_input_blocked(blocked: bool) -> void:
	input_blocked = blocked
	
	# Block inventory UI input
	var inventory_ui = get_tree().get_first_node_in_group("inventory_ui")
	if inventory_ui:
		inventory_ui.set_process_input(not blocked)
		inventory_ui.set_process(not blocked)
	
	# Block door interaction
	var door_area = get_node_or_null("DoorClickArea")
	if door_area:
		door_area.set_process_input(not blocked)
		door_area.monitoring = not blocked
		door_area.monitorable = not blocked
	
	# Block all items from being dragged
	for item in get_tree().get_nodes_in_group("items"):
		if item.has_method("set_input_blocked"):
			item.set_input_blocked(blocked)
		else:
			item.set_process_input(not blocked)
			item.input_pickable = not blocked

func check_submission(item_name: String) -> bool:
	if input_blocked:
		return false
	
	var expected: String = GlobalBackground.current_prompt_data.get("answer", "")

	if item_name == expected:
		prompt_text.text = "CORRECT..."
		GlobalBackground.doors_locked = true
		
		# ========== NEW: Block input immediately ==========
		set_input_blocked(true)
		# ========== END ==========
		
		feedback_timer.start()
		return true
	else:
		prompt_text.text = "...WRONG..."
		
		# ========== NEW: Block input immediately ==========
		set_input_blocked(true)
		# ========== END ==========
		
		feedback_timer.start()
		if has_node("/root/GameTimer"):
			GameTimer.reduce_time(GameTimer.WRONG_ITEM_PENALTY)
		return false

func _on_feedback_timeout() -> void:
	# ========== NEW: Unblock input when feedback ends ==========
	set_input_blocked(false)
	# ========== END ==========
	
	if GlobalBackground.current_prompt_data.get("text", "") != prompt_text.text:
		var was_correct: bool = (prompt_text.text == "CORRECT...")
		if was_correct:
			var has_more: bool = GlobalBackground.pick_new_prompt()
			if not has_more:
				_trigger_win()
				return
		display_current_riddle()
		GlobalBackground.doors_locked = false
	else:
		display_current_riddle()

func _trigger_win() -> void:
	set_input_blocked(true)
	
	if has_node("/root/GameTimer"):
		GameTimer.stop_timer()

	prompt_text.text = "YOU HAVE BROUGHT ALL THAT WAS ASKED..."
	await get_tree().create_timer(2.5).timeout

	GlobalBackground.reset_prompts()
	InventoryManager.clear_inventory()

	if has_node("/root/GameTimer"):
		GameTimer.reset_timer()

	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
