# settings.gd
extends CanvasLayer

@onready var music_slider    = $SettingsButton/SettingsContainer/MusicContainer/MusicSlider
@onready var sfx_slider      = $SettingsButton/SettingsContainer/SFXContainer/SFXHSlider
@onready var settings_panel  = $SettingsButton
@onready var texture_button  = $TextureButton
@onready var overlay         = $Overlay

func _ready():
	settings_panel.hide()
	overlay.hide()
	texture_button.pressed.connect(_on_settings_button_pressed)
	overlay.gui_input.connect(_on_overlay_input)
	texture_button.mouse_entered.connect(_on_hover_enter)
	texture_button.mouse_exited.connect(_on_hover_exit)

func _on_hover_enter():
	var tween = create_tween()
	tween.tween_property(texture_button, "scale", Vector2(0.15, 0.135), 0.15)
	tween.parallel().tween_property(texture_button, "rotation_degrees", 20.0, 0.15)

func _on_hover_exit():
	var tween = create_tween()
	tween.tween_property(texture_button, "scale", Vector2(0.1325021, 0.11865279), 0.15)
	tween.parallel().tween_property(texture_button, "rotation_degrees", 0.0, 0.15)

func _on_settings_button_pressed():
	settings_panel.show()
	overlay.show()
	_set_doors_active(false)
	# Pause the gameplay timer while settings is open
	if has_node("/root/GameTimer"):
		GameTimer.pause_timer()

func _on_close_pressed():
	settings_panel.hide()
	overlay.hide()
	_set_doors_active(true)
	# Resume the gameplay timer when settings is closed
	if has_node("/root/GameTimer"):
		GameTimer.resume_timer()

func _on_overlay_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		settings_panel.hide()
		overlay.hide()
		_set_doors_active(true)
		# Resume the gameplay timer when clicking outside to close
		if has_node("/root/GameTimer"):
			GameTimer.resume_timer()

func _set_doors_active(active: bool):
	var door_area = get_parent().get_node_or_null("DoorClickArea")
	if door_area:
		door_area.set_process_input(active)
		door_area.monitoring  = active
		door_area.monitorable = active

func _on_music_slider_value_changed(value: float):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(value)
	)

func _on_sfxh_slider_value_changed(value: float):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(value)
	)

func _on_restart_pressed():
	# Reset timer fully before reloading so no ghost state carries over
	if has_node("/root/GameTimer"):
		GameTimer.reset_timer()
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	# Reset timer fully before leaving so next game starts clean
	if has_node("/root/GameTimer"):
		GameTimer.reset_timer()
	# Clear prompt state so corridor._ready() treats the next game as fresh
	if has_node("/root/GlobalBackground"):
		GlobalBackground.reset_prompts()
	InventoryManager.clear_inventory()
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
