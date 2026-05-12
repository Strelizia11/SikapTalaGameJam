extends Node2D

const GAMEPLAY_DURATION  : float = 420.0  # 7 minutes
const WRONG_ITEM_PENALTY : float = 30.0   # seconds lost per wrong item

var _time_left : float = GAMEPLAY_DURATION
var _running   : bool  = false
var _dead      : bool  = false

var _label : Label

# ── Called by corridor.gd when the game starts ───────────────────────────────
func start_timer() -> void:
	_time_left = GAMEPLAY_DURATION
	_dead      = false
	_running   = true
	_label.visible = true
	_refresh_label()

func stop_timer() -> void:
	_running = false

func reduce_time(seconds: float) -> void:
	if not _running or _dead:
		return
	_time_left = maxf(_time_left - seconds, 0.0)
	_refresh_label()
	if _time_left <= 0.0:
		_on_time_up()

func get_time_left_formatted() -> String:
	var t := int(_time_left)
	return "%02d:%02d" % [t / 60, t % 60]

# ── Godot lifecycle ───────────────────────────────────────────────────────────
func _ready() -> void:
	# Build a CanvasLayer so the label always renders on top of everything
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	_label = Label.new()
	_label.text = get_time_left_formatted()
	_label.visible = false  # hidden until start_timer() is called

	# Black text, large enough to read easily
	_label.add_theme_color_override("font_color", Color(255, 255, 255, 255))
	_label.add_theme_font_size_override("font_size", 52)

	# Top-left, 16 px inset from each edge
	_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_label.offset_left   = 16
	_label.offset_top    = 16
	_label.offset_right  = 220
	_label.offset_bottom = 80

	canvas.add_child(_label)

func _process(delta: float) -> void:
	if not _running or _dead:
		return
	_time_left -= delta
	if _time_left <= 0.0:
		_time_left = 0.0
		_refresh_label()
		_on_time_up()
		return
	_refresh_label()

# ── internal ──────────────────────────────────────────────────────────────────
func _refresh_label() -> void:
	_label.text = get_time_left_formatted()

func _on_time_up() -> void:
	if _dead:
		return
	_dead    = true
	_running = false
	_do_death()

func _do_death() -> void:
	# ── JUMPSCARE PLACEHOLDER ─────────────────────────────────────────────────
	# Replace the lines below with your jumpscare scene once it exists.
	# Example:
	#   var js = preload("res://scenes/jumpscare.tscn").instantiate()
	#   get_tree().current_scene.add_child(js)
	#   js.play()
	#   await js.finished
	await get_tree().create_timer(1.0).timeout
	# ── END JUMPSCARE PLACEHOLDER ─────────────────────────────────────────────

	_label.visible = false
	GlobalBackground.reset_prompts()
	InventoryManager.clear_inventory()
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
