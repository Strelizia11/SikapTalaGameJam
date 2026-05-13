# settings.gd
extends CanvasLayer

@onready var music_slider = $SettingsButton/SettingsContainer/MusicContainer/MusicSlider
@onready var sfx_slider = $SettingsButton/SettingsContainer/SFXContainer/SFXHSlider
@onready var settings_panel = $SettingsButton
@onready var texture_button = $TextureButton
@onready var overlay = $Overlay

# Volume settings (saved between scenes)
var music_volume: float = 1.0
var sfx_volume: float = 1.0

func _ready():
	settings_panel.hide()
	overlay.hide()
	
	# Force slider values to 1.0 (max) before anything else
	if music_slider:
		music_slider.min_value = 0.0
		music_slider.max_value = 1.0
		music_slider.value = 1.0  # Set to max
		music_slider.set_value_no_signal(1.0)  # Force without triggering signal
	
	if sfx_slider:
		sfx_slider.min_value = 0.0
		sfx_slider.max_value = 1.0
		sfx_slider.value = 1.0  # Set to max
		sfx_slider.set_value_no_signal(1.0)  # Force without triggering signal
	
	_init_volume_settings()
	
	if texture_button:
		texture_button.pressed.connect(_on_settings_button_pressed)
		texture_button.mouse_entered.connect(_on_hover_enter)
		texture_button.mouse_exited.connect(_on_hover_exit)
	
	if overlay:
		overlay.gui_input.connect(_on_overlay_input)
	
	if music_slider:
		music_slider.value_changed.connect(_on_music_slider_value_changed)
	
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfxh_slider_value_changed)

func _init_volume_settings():
	# Set volumes to max (1.0 = -0 dB? No, linear_to_db(1.0) = 0 dB which is max)
	# linear_to_db: 0.5 = -6dB, 0.75 = -2.5dB, 1.0 = 0dB (max)
	
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(1.0))
		print("Music bus set to: ", linear_to_db(1.0), " dB")
	
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(1.0))
		print("SFX bus set to: ", linear_to_db(1.0), " dB")

func _on_hover_enter():
	if not texture_button:
		return
	var tween = create_tween()
	tween.tween_property(texture_button, "scale", Vector2(0.15, 0.135), 0.15)
	tween.parallel().tween_property(texture_button, "rotation_degrees", 1.0, 0.15)

func _on_hover_exit():
	if not texture_button:
		return
	var tween = create_tween()
	tween.tween_property(texture_button, "scale", Vector2(0.1325021, 0.11865279), 0.15)
	tween.parallel().tween_property(texture_button, "rotation_degrees", 0.0, 0.15)

func _on_settings_button_pressed():
	if settings_panel:
		settings_panel.show()
	if overlay:
		overlay.show()
	_set_doors_active(false)
	if has_node("/root/GameTimer"):
		GameTimer.pause_timer()

func _on_close_pressed():
	if settings_panel:
		settings_panel.hide()
	if overlay:
		overlay.hide()
	_set_doors_active(true)
	if has_node("/root/GameTimer"):
		GameTimer.resume_timer()

func _on_overlay_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if settings_panel:
			settings_panel.hide()
		if overlay:
			overlay.hide()
		_set_doors_active(true)
		if has_node("/root/GameTimer"):
			GameTimer.resume_timer()

func _set_doors_active(active: bool):
	var door_area = get_parent().get_node_or_null("DoorClickArea")
	if door_area:
		door_area.set_process_input(active)
		door_area.monitoring = active
		door_area.monitorable = active

func _on_music_slider_value_changed(value: float):
	music_volume = value
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

func _on_sfxh_slider_value_changed(value: float):
	sfx_volume = value
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))

func _on_restart_pressed():
	if settings_panel:
		settings_panel.hide()
	if overlay:
		overlay.hide()
	_set_doors_active(true)
	_reset_game_state()
	get_tree().change_scene_to_file("res://scenes/corridor.tscn")

func _on_main_menu_pressed():
	if settings_panel:
		settings_panel.hide()
	if overlay:
		overlay.hide()
	_reset_game_state()
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

func _reset_game_state():
	if has_node("/root/GameTimer"):
		GameTimer.reset_timer()
	if has_node("/root/InventoryManager"):
		InventoryManager.clear_inventory()
	if has_node("/root/GlobalBackground"):
		if GlobalBackground.has_method("reset_prompts"):
			GlobalBackground.reset_prompts()
