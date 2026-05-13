# corridor.gd
extends Control

@onready var prompt_text       = $Node2D/PromtWall
@onready var transition_player = $Transition/Transitions/AnimationPlayer

var feedback_timer: Timer

func _ready() -> void:
	transition_player.play("black_to_fade")
	$Inventory.current_room = "corridor"

	feedback_timer = Timer.new()
	feedback_timer.one_shot  = true
	feedback_timer.wait_time = 1.5
	feedback_timer.timeout.connect(_on_feedback_timeout)
	add_child(feedback_timer)

	if GlobalBackground.current_prompt_data.is_empty():
		GlobalBackground.reset_prompts()
		GlobalBackground.pick_new_prompt()
	# Always (re)start the timer when entering the corridor fresh.
	# reset_timer() is always called before any return to the main menu,
	# so _running is guaranteed to be false here — starting it is safe.
	if has_node("/root/GameTimer") and not GameTimer._running:
		GameTimer.start_timer()

	display_current_riddle()

func display_current_riddle() -> void:
	prompt_text.text = GlobalBackground.current_prompt_data.get("text", "???")

func check_submission(item_name: String) -> bool:
	var expected: String = GlobalBackground.current_prompt_data.get("answer", "")

	if item_name == expected:
		prompt_text.text = "CORRECT..."
		GlobalBackground.doors_locked = true
		feedback_timer.start()
		return true
	else:
		prompt_text.text = "...WRONG..."
		feedback_timer.start()
		if has_node("/root/GameTimer"):
			GameTimer.reduce_time(GameTimer.WRONG_ITEM_PENALTY)
		return false

func _on_feedback_timeout() -> void:
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
	if has_node("/root/GameTimer"):
		GameTimer.stop_timer()

	prompt_text.text = "YOU HAVE BROUGHT ALL THAT WAS ASKED..."
	await get_tree().create_timer(2.5).timeout

	GlobalBackground.reset_prompts()
	InventoryManager.clear_inventory()

	# Reset timer (hides label) before going to main menu
	if has_node("/root/GameTimer"):
		GameTimer.reset_timer()

	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
