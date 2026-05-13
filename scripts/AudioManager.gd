extends Node

var music_player : AudioStreamPlayer
var current_music = null

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

func play_sfx(sound):
	var player = AudioStreamPlayer.new()
	add_child(player)

	player.stream = sound
	player.play()

	player.finished.connect(player.queue_free)

func play_bgm(music):
	# Prevent replaying same music
	if current_music == music and music_player.playing:
		return

	current_music = music

	music_player.stream = music
	music_player.play()

func stop_bgm():
	music_player.stop()
	current_music = null
