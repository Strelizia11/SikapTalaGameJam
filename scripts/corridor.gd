extends Control

@onready var prompt_text = $Node2D/PromtWall
@onready var transition_player = $Transition/Transitions/AnimationPlayer
@onready var feedback_timer = Timer.new()

# --- THE PROMPTS LIST HAS BEEN REMOVED (It's now in GlobalBackground) ---

func _ready():
	transition_player.play("black_to_fade")
	
	# Fix the error from earlier by ensuring this exists in Inventory.gd
	$Inventory.current_room = "corridor"

	# One-shot timer setup
	feedback_timer.one_shot = true
	feedback_timer.wait_time = 1.5
	feedback_timer.timeout.connect(_on_feedback_timeout)
	add_child(feedback_timer)

	# Initial prompt setup using GlobalBackground
	if GlobalBackground.current_prompt_data.is_empty():
		GlobalBackground.pick_new_prompt()
	
	display_current_riddle()

# Helper function to just update the label text
func display_current_riddle():
	prompt_text.text = GlobalBackground.current_prompt_data["text"]

func check_submission(item_name: String) -> bool:
	# Check against the answer stored in the Global script
	if item_name == GlobalBackground.current_prompt_data["answer"]:
		InventoryManager.remove_item(item_name)
		
		var inventory_ui = get_tree().get_first_node_in_group("inventory_ui")
		if inventory_ui:
			inventory_ui.refresh()
			
		prompt_text.text = "CORRECT..."
		feedback_timer.start()
		return true
	else:
		prompt_text.text = "...WRONG..."
		feedback_timer.start()
		return false

func _on_feedback_timeout():
	# If they got it right, tell GlobalBackground to pick a new one
	if prompt_text.text == "CORRECT...":
		GlobalBackground.pick_new_prompt()
		display_current_riddle()
	else:
		# If they got it wrong, just show the current riddle again
		display_current_riddle()
