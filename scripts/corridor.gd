# corridor.gd
extends Control

@onready var prompt_text = $Node2D/PromtWall
@onready var transition_player = $Transition/Transitions/AnimationPlayer
@onready var feedback_timer = Timer.new()

const PROMPTS = [
	{"text": "BRING ME WHAT NO LONGER LIVES", "answer": "dead-flower"},
	{"text": "BRING ME THE FACE YOU HIDE BEHIND", "answer": "surgical-mask"},
	{"text": "BRING ME WHAT KEEPS WATCHING", "answer": "clock"},
	{"text": "BRING ME WHAT ENDS THINGS", "answer": "knife"},
	{"text": "BRING ME THE STAIN THAT REFUSES TO HIDE", "answer": "bloody-handkerchief"},
	{"text": "BRING ME WHAT LETS YOU FORGET THE PAIN", "answer": "medicine"},
	{"text": "BRING ME THE ONE THAT LIES TO YOU", "answer": "mirror"}
]

var current_prompt = {}

func _ready():
	transition_player.play("black_to_fade")
	$Inventory.current_room = "corridor"

	# One-shot timer for clearing feedback text
	feedback_timer.one_shot = true
	feedback_timer.wait_time = 1.5
	feedback_timer.timeout.connect(_on_feedback_timeout)
	add_child(feedback_timer)

	show_prompt()

func show_prompt():
	current_prompt = PROMPTS[randi() % PROMPTS.size()]
	prompt_text.text = current_prompt["text"]

func check_submission(item_name: String) -> bool:
	if item_name == current_prompt["answer"]:
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
	if prompt_text.text != current_prompt["text"]:
		# After showing correct, pick a new prompt
		if prompt_text.text == "CORRECT...":
			show_prompt()
		else:
			# Wrong — just restore the prompt
			prompt_text.text = current_prompt["text"]
