extends Node

const GAMEPLAY_DURATION  : float = 420.0
const WRONG_ITEM_PENALTY : float = 30.0

# ── TIMER POSITION & SIZE SETTINGS (Edit these values) ───────────────────────
# Position (X, Y) - screen coordinates
var TIMER_POSITION_X : float = 850.0  # Move right (default 16)
var TIMER_POSITION_Y : float = 16.0    # Keep at top

# Size settings
var TIMER_FONT_SIZE : int = 100       # Bigger font (default 52)
var TIMER_WIDTH : float = 280          # Wider box (default 220)
var TIMER_HEIGHT : float = 150         # Taller box (default 80)

# Color (R, G, B, A) - 255 is max
var TIMER_COLOR_R : int = 255
var TIMER_COLOR_G : int = 255
var TIMER_COLOR_B : int = 255
var TIMER_COLOR_A : int = 255
# ─────────────────────────────────────────────────────────────────────────────

var CUSTOM_FONT_PATH : String = "res://assets/fonts/Digital Dismay.otf"
var FONT_STYLE : String = "bold"

var _time_left     : float = GAMEPLAY_DURATION
var _running       : bool  = false
var _dead          : bool  = false
var _death_started : bool  = false

var _canvas : CanvasLayer
var _label  : Label

signal timer_updated(time_left: float)
signal player_died

# ── public ────────────────────────────────────────────────────────────────────

func start_timer() -> void:
	_time_left     = GAMEPLAY_DURATION
	_dead          = false
	_death_started = false
	_running       = true
	_label.visible = true
	_refresh_label()
	emit_signal("timer_updated", _time_left)

func stop_timer() -> void:
	_running = false

func pause_timer() -> void:
	_running = false

func resume_timer() -> void:
	if not _dead:
		_running = true

func reset_timer() -> void:
	# Full reset of all state
	_running       = false
	_dead          = false
	_death_started = false
	_time_left     = GAMEPLAY_DURATION
	_refresh_label()
	if _label:
		_label.visible = false

func reduce_time(seconds: float) -> void:
	if not _running or _dead:
		return
	_time_left = maxf(_time_left - seconds, 0.0)
	_refresh_label()
	emit_signal("timer_updated", _time_left)
	if _time_left <= 0.0:
		_on_time_up()

func get_time_left() -> float:
	return _time_left

func get_time_left_formatted() -> String:
	var t := int(_time_left)
	return "%02d:%02d" % [t / 60, t % 60]

# ── lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	_canvas       = CanvasLayer.new()
	_canvas.layer = 10
	add_child(_canvas)

	_label         = Label.new()
	_label.text    = get_time_left_formatted()
	_label.visible = false

	# Try to load and apply custom font
	if CUSTOM_FONT_PATH != "" and ResourceLoader.exists(CUSTOM_FONT_PATH):
		var custom_font = load(CUSTOM_FONT_PATH)
		if custom_font:
			_label.add_theme_font_override("font", custom_font)
			print("Custom font loaded: ", CUSTOM_FONT_PATH)
		else:
			print("Failed to load font: ", CUSTOM_FONT_PATH)
	else:
		print("Font file not found: ", CUSTOM_FONT_PATH)
	
	# Apply custom color
	var timer_color = Color(
		TIMER_COLOR_R / 255.0,
		TIMER_COLOR_G / 255.0,
		TIMER_COLOR_B / 255.0,
		TIMER_COLOR_A / 255.0
	)
	_label.add_theme_color_override("font_color", timer_color)
	
	# Apply custom font size
	_label.add_theme_font_size_override("font_size", TIMER_FONT_SIZE)

	_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_label.grow_horizontal = Control.GROW_DIRECTION_END
	_label.grow_vertical   = Control.GROW_DIRECTION_END
	
	# Apply custom position and size
	_label.offset_left   = TIMER_POSITION_X
	_label.offset_top    = TIMER_POSITION_Y
	_label.offset_right  = TIMER_POSITION_X + TIMER_WIDTH
	_label.offset_bottom = TIMER_POSITION_Y + TIMER_HEIGHT

	_canvas.add_child(_label)

	# Don't auto-start timer - wait for scene to call start_timer()

func _process(delta: float) -> void:
	if not _running or _dead:
		return
	_time_left -= delta
	_refresh_label()
	if _time_left <= 0.0:
		_time_left = 0.0
		_refresh_label()
		_on_time_up()

# ── internal ──────────────────────────────────────────────────────────────────

func _refresh_label() -> void:
	if _label and is_instance_valid(_label):
		_label.text = get_time_left_formatted()

func _on_time_up() -> void:
	if _dead:
		return
	_dead    = true
	_running = false
	emit_signal("player_died")
	emit_signal("timer_updated", 0.0)
	_do_death()

func _do_death() -> void:
	if _death_started:
		return
	_death_started = true

	# ── JUMPSCARE ─────────────────────────────────────────────────────────────
	var js_scene = load("res://scenes/Jumpscare.tscn")  # capital J to match your file
	if js_scene:
		var js = js_scene.instantiate()
		get_tree().root.add_child(js)
		js.play()
		await js.finished
		js.queue_free()
	else:
		await get_tree().create_timer(1.0).timeout
	# ── END JUMPSCARE ─────────────────────────────────────────────────────────

	if not is_instance_valid(self):
		return

	call_deferred("_change_to_main_menu")

func _change_to_main_menu() -> void:
	reset_timer()
	_running = false
	_dead = false
	_death_started = false

	# Clear inventory so items don't carry over after death or restart
	if has_node("/root/InventoryManager"):
		InventoryManager.clear_inventory()

	# Reset prompts so next game starts fresh
	if has_node("/root/GlobalBackground"):
		if GlobalBackground.has_method("reset_prompts"):
			GlobalBackground.reset_prompts()

	# Reset round state
	if has_node("/root/RoundManager"):
		RoundManager.reset_game()

	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
