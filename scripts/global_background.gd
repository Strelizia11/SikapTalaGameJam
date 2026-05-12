extends Node2D

var current_bg_path: String = "res://assets/sprites/kitchen/BLUE.png"

const PROMPTS = [
	{
		"text": "BRING ME WHAT NO LONGER LIVES",
		"answer": "dead-flower",
		"bg": "res://assets/sprites/kitchen/BLUE.png"
	},
	{
		"text": "BRING ME THE FACE YOU HIDE BEHIND",
		"answer": "surgical-mask",
		"bg": "res://assets/sprites/kitchen/BLUE.png"
	},
	{
		"text": "BRING ME WHAT KEEPS WATCHING",
		"answer": "clock",
		"bg": "res://assets/sprites/kitchen/BLUE.png"
	},
	{
		"text": "BRING ME WHAT ENDS THINGS",
		"answer": "knife",
		"bg": "res://assets/sprites/kitchen/BLUE.png"
	},
	{
		"text": "BRING ME THE STAIN THAT REFUSES TO HIDE",
		"answer":"bloody-handkerchief",
		"bg": "res://assets/sprites/kitchen/BLUE.png"
	},
	{
		"text": "BRING ME WHAT LETS YOU FORGET THE PAIN",
		"answer":"medicine",
		"bg": "res://assets/sprites/kitchen/BLUE.png"
	},
	{
		"text": "BRING ME THE ONE THAT LIES TO YOU",
		"answer":"mirror",
		"bg": "res://assets/sprites/kitchen/BLUE.png"
	}
]

var current_prompt_data = {}

func pick_new_prompt():
	current_prompt_data = PROMPTS.pick_random()
	current_bg_path = current_prompt_data["bg"]
