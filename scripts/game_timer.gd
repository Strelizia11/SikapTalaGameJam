extends Node

const GAMEPLAY_DURATION  : float = 420.0
const WRONG_ITEM_PENALTY : float = 30.0

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
	# Call this before ANY scene change to main menu or restart.
	# Fully wipes all state so the next game starts clean.
	_running       = false
	_dead          = false
	_death_started = false
	_time_left     = GAMEPLAY_DURATION
	if _label:
		_label.visible = false
	_refresh_label()

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

	_label.add_theme_color_override("font_color", Color(255, 255, 255, 255))
	_label.add_theme_font_size_override("font_size", 52)

	_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_label.grow_horizontal = Control.GROW_DIRECTION_END
	_label.grow_vertical   = Control.GROW_DIRECTION_END
	_label.offset_left   = 16
	_label.offset_top    = 16
	_label.offset_right  = 220
	_label.offset_bottom = 80

	_canvas.add_child(_label)

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
	if _label:
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
	# Prevent stacked awaits from multiple death triggers making the game unclickable
	if _death_started:
		return
	_death_started = true

	# ── JUMPSCARE PLACEHOLDER ─────────────────────────────────────────────────
	# Replace the await below with your jumpscare scene once it's ready.
	# Example:
	#   var js = preload("res://scenes/jumpscare.tscn").instantiate()
	#   get_tree().current_scene.add_child(js)
	#   js.play()
	#   await js.finished
	await get_tree().create_timer(1.0).timeout
	# ── END JUMPSCARE PLACEHOLDER ─────────────────────────────────────────────

	if not is_instance_valid(self):
		return

	GlobalBackground.reset_prompts()
	InventoryManager.clear_inventory()
	reset_timer()  # hides label + wipes state before scene change
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
