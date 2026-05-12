extends Node2D

var current_bg_path1: String = "res://assets/sprites/kitchen/BLUE.png"
var current_bg_path2: String = "res://assets/sprites/kitchen/BLUE.png"

const PROMPTS = [
	{
		"text": "BRING ME WHAT NO LONGER LIVES",
		"answer": "dead-flower",
		"bg1": "res://assets/sprites/kitchen/BLUE.png",
		"bg2": "res://assets/sprites/kitchen/BLUE.png"
	},
	{
		"text": "BRING ME THE FACE YOU HIDE BEHIND",
		"answer": "surgical-mask",
		"bg1": "res://assets/sprites/kitchen/VIOLET.png",
		"bg2": "res://assets/sprites/kitchen/VIOLET.png"
	},
	{
		"text": "BRING ME WHAT KEEPS WATCHING",
		"answer": "clock",
		"bg1": "res://assets/sprites/kitchen/RED.png",
		"bg2": "res://assets/sprites/kitchen/RED.png"
	},
	{
		"text": "BRING ME WHAT ENDS THINGS",
		"answer": "knife",
		"bg1": "res://assets/sprites/kitchen/RED.png",
		"bg2": "res://assets/sprites/kitchen/RED.png"
	},
	{
		"text": "BRING ME THE STAIN THAT REFUSES TO HIDE GUILT",
		"answer":"bloody-handkerchief",
		"bg1": "res://assets/sprites/kitchen/RED.png",
		"bg2": "res://assets/sprites/kitchen/RED.png"
	},
	{
		"text": "BRING ME WHAT LETS YOU FORGET THE PAIN",
		"answer":"medicine",
		"bg1": "res://assets/sprites/kitchen/BLUE.png",
		"bg2": "res://assets/sprites/kitchen/BLUE.png"
	},
	{
		"text": "BRING ME THE ONE THAT LIES TO YOU",
		"answer":"mirror",
		"bg1": "res://assets/sprites/kitchen/VIOLET.png",
		"bg2": "res://assets/sprites/kitchen/VIOLET.png"
	}
]

var current_prompt_data = {}

func pick_new_prompt():
	current_prompt_data = PROMPTS.pick_random()
	current_bg_path1 = current_prompt_data["bg1"]
	current_bg_path2 = current_prompt_data["bg2"]
