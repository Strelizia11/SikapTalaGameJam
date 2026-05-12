extends Control

@onready var prompt_text = $Node2D/PromtWall
@onready var transition_player = $Transition/Transitions/AnimationPlayer

const PROMPTS = [
	{"text": "BRING ME WHAT NO LONGER LIVES", "answer": "dead-flower"},
	{"text": "BRING ME THE FACE YOU HIDE BEHIND", "answer": "surgical-mask"},
	{"text": "BRING ME WHAT KEEPS WATCHING", "answer": "clock"},
	{"text": "BRING ME WHAT ENDS THINGS", "answer": "knife"},
	{"text": "BRING ME THE STAIN THAT REFUSES TO HIDE","answer":"bloody-handkerchief"},
	{"text": "BRING ME WHAT LETS YOU FORGET THE PAIN","answer":"medicine"},
	{"text": "BRING ME THE ONE THAT LIES TO YOU","answer":"mirror"}
]

var current_prompt = {}

func _ready():
	transition_player.play("black_to_fade")
	show_prompt()

func show_prompt():
	current_prompt = PROMPTS[randi() % PROMPTS.size()]
	prompt_text.text = current_prompt["text"]

func check_submission(item_name: String) -> bool:
	if item_name == current_prompt["answer"]:
		show_prompt()
		return true
	return false
