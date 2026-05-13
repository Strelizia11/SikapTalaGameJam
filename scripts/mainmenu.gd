extends Node2D

@onready var transition_player = $Transition/Transitions/AnimationPlayer
@onready var overlay1 = $Transition/Transitions/ColorRect
@onready var overlay2 = $Transition/Transitions/TextureRect

var credits_popup: Panel

func _ready():
	$Menu/START.pressed.connect(_on_start_pressed)
	$Menu/QUIT.pressed.connect(_on_quit_pressed)
	$Menu/CREDITS.pressed.connect(_on_credits_pressed)

	transition_player.play("Trigger")
	overlay1.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay2.mouse_filter = Control.MOUSE_FILTER_STOP
	await transition_player.animation_finished
	overlay1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay2.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_build_credits_popup()

func _build_credits_popup():
	# CanvasLayer so it renders on top of everything
	var canvas = CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	# Dark background overlay
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas.add_child(bg)

	# Panel
	credits_popup = Panel.new()
	credits_popup.custom_minimum_size = Vector2(700, 480)
	credits_popup.position = Vector2(610, 300)
	canvas.add_child(credits_popup)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 16)
	vbox.offset_left = 20
	vbox.offset_right = -20
	vbox.offset_top = 20
	vbox.offset_bottom = -20
	credits_popup.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "CREDITS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", load("res://assets/fonts/BebasNeue-Regular.ttf"))
	title.add_theme_font_size_override("font_size", 50)
	vbox.add_child(title)

	# Separator
	var sep = HSeparator.new()
	vbox.add_child(sep)

	# Credits body
	var body = Label.new()
	body.text = """Game Design & Programming
    BitByBit Team
	
	Art & Assets
    BitByBit Team

	Music
    BitByBit Team

	Special Thanks
    Universidad de Dagupan"""
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_override("font", load("res://assets/fonts/BebasNeue-Regular.ttf"))
	body.add_theme_font_size_override("font_size", 25)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(body)

	# Spacer
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	# Close button
	var close_btn = Button.new()
	close_btn.text = "CLOSE"
	close_btn.add_theme_font_override("font", load("res://assets/fonts/BebasNeue-Regular.ttf"))
	close_btn.add_theme_font_size_override("font_size", 52)
	close_btn.pressed.connect(_on_credits_closed)
	vbox.add_child(close_btn)

	# Hide by default — also hide the bg together
	credits_popup.visible = false
	bg.visible = false

	# Store bg reference for toggling
	credits_popup.set_meta("bg", bg)

func _on_start_pressed():
	randomize()
	InventoryManager.reset_kitchen_layout_for_new_game()
	InventoryManager.reset_toilet_layout_for_new_game()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_credits_pressed():
	credits_popup.visible = true
	credits_popup.get_meta("bg").visible = true

func _on_credits_closed():
	credits_popup.visible = false
	credits_popup.get_meta("bg").visible = false
