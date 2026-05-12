extends CanvasLayer

@onready var music_slider = $SettingsButton/SettingsContainer/MusicContainer/MusicSlider
@onready var sfx_slider = $SettingsButton/SettingsContainer/SFXContainer/SFXHSlider
@onready var settings_panel = $SettingsButton
@onready var settings_container = $SettingsButton/SettingsContainer
@onready var texture_button = $TextureButton

func _ready():
	settings_panel.hide()
	texture_button.pressed.connect(_on_settings_button_pressed)
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.value = 1.0
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.value = 1.0

func _on_settings_button_pressed():
	settings_panel.show()

func _on_close_pressed():
	settings_panel.hide()

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
