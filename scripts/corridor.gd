extends Control

@onready var prompt_text = $Node2D/PromtWall

const PROMPTS = [
	{"text": "Bring me something that bounces", "answer": "ball"},
	{"text": "Bring me something that cuts", "answer": "scissors"},
	{"text": "Bring me something that holds water", "answer": "cup"},
	{"text": "Bring me something that makes noise", "answer": "bell"}
]

var current_prompt = {}

func _ready():
	show_prompt()

func show_prompt():
	current_prompt = PROMPTS[randi() % PROMPTS.size()]
	prompt_text.text = current_prompt["text"]

func _on_kitchen_door_pressed():
	get_tree().change_scene_to_file("res://scenes/kitchen.tscn")

func _on_toilet_door_pressed():
	get_tree().change_scene_to_file("res://scenes/toilet.tscn")

func check_submission(item_name: String) -> bool:
	if item_name == current_prompt["answer"]:
		show_prompt()
		return true
	return false
