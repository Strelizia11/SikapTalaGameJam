extends Control

@onready var prompt_text       = $Node2D/PromtWall
@onready var transition_player = $Transition/Transitions/AnimationPlayer

var feedback_timer: Timer

func _ready() -> void:
	transition_player.play("black_to_fade")
	$Inventory.current_room = "corridor"

	# Feedback timer for showing CORRECT / WRONG messages
	feedback_timer = Timer.new()
	feedback_timer.one_shot   = true
	feedback_timer.wait_time  = 1.5
	feedback_timer.timeout.connect(_on_feedback_timeout)
	add_child(feedback_timer)

	# First time entering: reset prompts and pick the first riddle
	if GlobalBackground.current_prompt_data.is_empty():
		GlobalBackground.reset_prompts()
		GlobalBackground.pick_new_prompt()
		# Start the gameplay timer only on the very first entry
		if has_node("/root/GameTimer"):
			GameTimer.start_timer()
			# [TIMER LABEL] Connect the signal to update the label every second
			# GameTimer.timer_updated.connect(_on_timer_updated)   # [TIMER LABEL]

	display_current_riddle()

# ── [TIMER LABEL] Uncomment this function if you add a TimerLabel node ──────
# func _on_timer_updated(time_left: float) -> void:
# 	timer_label.text = GameTimer.get_time_left_formatted()
# ── end timer label ──────────────────────────────────────────────────────────

func display_current_riddle() -> void:
	prompt_text.text = GlobalBackground.current_prompt_data.get("text", "???")

func check_submission(item_name: String) -> bool:
	var expected: String = GlobalBackground.current_prompt_data.get("answer", "")

	if item_name == expected:
		prompt_text.text        = "CORRECT..."
		GlobalBackground.doors_locked = true
		feedback_timer.start()
		return true
	else:
		prompt_text.text = "...WRONG..."
		feedback_timer.start()

		# ── TIME PENALTY ─────────────────────────────────────────────────────
		# Deduct 30 seconds for submitting the wrong item.
		if has_node("/root/GameTimer"):
			GameTimer.reduce_time(GameTimer.WRONG_ITEM_PENALTY)
		# ── end penalty ───────────────────────────────────────────────────────

		return false

func _on_feedback_timeout() -> void:
	if GlobalBackground.current_prompt_data.get("text", "") != prompt_text.text:
		# We showed CORRECT or WRONG — decide what's next
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
	# Stop the timer so it doesn't kill the player during the win sequence
	if has_node("/root/GameTimer"):
		GameTimer.stop_timer()

	prompt_text.text = "YOU HAVE BROUGHT ALL THAT WAS ASKED..."
	await get_tree().create_timer(2.5).timeout

	# Reset state for a fresh game
	GlobalBackground.reset_prompts()
	InventoryManager.clear_inventory()
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
