extends CanvasLayer

@onready var music_slider = $SettingsButton/SettingsContainer/MusicContainer/MusicSlider
@onready var sfx_slider = $SettingsButton/SettingsContainer/SFXContainer/SFXHSlider
@onready var settings_panel = $SettingsButton
@onready var settings_container = $SettingsButton/SettingsContainer
@onready var texture_button = $TextureButton
@onready var overlay = $Overlay

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

func _on_close_pressed():
	settings_panel.hide()
	overlay.hide()
	_set_doors_active(true)

func _on_overlay_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		settings_panel.hide()
		overlay.hide()
		_set_doors_active(true)

func _set_doors_active(active: bool):
	var door_area = get_parent().get_node_or_null("DoorClickArea")
	if door_area:
		door_area.set_process_input(active)
		door_area.monitoring = active
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
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
