extends Control

@onready var prompt_text = $Node2D/PromtWall
@onready var transition_player = $Transition/Transitions/AnimationPlayer

# No more PROMPTS list here! It's all in GlobalBackground now.

func _ready():
	# Tell the global script to pick a new riddle
	GlobalBackground.pick_new_prompt()
	
	transition_player.play("black_to_fade")
	update_ui()

func update_ui():
	# Get the text directly from the global script
	prompt_text.text = GlobalBackground.current_prompt_data["text"]

func check_submission(item_name: String) -> bool:
	# Check against the answer stored in the global script
	if item_name == GlobalBackground.current_prompt_data["answer"]:
		GlobalBackground.pick_new_prompt() # Pick a new one globally
		update_ui() # Refresh this screen
		return true
	return false
