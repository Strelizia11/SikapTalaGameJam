# corridor.gd
extends Control

@onready var prompt_text = $Node2D/PromtWall
@onready var transition_player = $Transition/Transitions/AnimationPlayer

var feedback_timer: Timer

func _ready():
	transition_player.play("black_to_fade")
	$Inventory.current_room = "corridor"

	feedback_timer = Timer.new()
	feedback_timer.one_shot = true
	feedback_timer.wait_time = 1.5
	feedback_timer.timeout.connect(_on_feedback_timeout)
	add_child(feedback_timer)

	# First time entering: reset and pick first prompt
	if GlobalBackground.current_prompt_data.is_empty():
		GlobalBackground.reset_prompts()
		GlobalBackground.pick_new_prompt()

	display_current_riddle()

func display_current_riddle():
	prompt_text.text = GlobalBackground.current_prompt_data.get("text", "???")

func check_submission(item_name: String) -> bool:
	var expected = GlobalBackground.current_prompt_data.get("answer", "")
	if item_name == expected:
		prompt_text.text = "CORRECT..."
		GlobalBackground.doors_locked = true
		feedback_timer.start()
		return true
	else:
		prompt_text.text = "...WRONG..."
		feedback_timer.start()
		return false

func _on_feedback_timeout():
	if GlobalBackground.current_prompt_data.get("text", "") != prompt_text.text:
		# We showed CORRECT or WRONG — decide what's next
		var was_correct = (prompt_text.text == "CORRECT...")
		if was_correct:
			# Try to pick the next prompt
			var has_more = GlobalBackground.pick_new_prompt()
			if not has_more:
				# All prompts done — player wins!
				_trigger_win()
				return
		# Either wrong (show same prompt again) or next prompt ready
		display_current_riddle()
		GlobalBackground.doors_locked = false
	else:
		display_current_riddle()

func _trigger_win():
	prompt_text.text = "YOU HAVE BROUGHT ALL THAT WAS ASKED..."
	await get_tree().create_timer(2.5).timeout
	# Clear state for a fresh new game
	GlobalBackground.reset_prompts()
	InventoryManager.clear_inventory()
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
