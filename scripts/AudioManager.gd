extends Node

func play_sfx(sound):
	var player = AudioStreamPlayer.new()
	add_child(player)

	player.stream = sound
	player.play()

	player.finished.connect(player.queue_free)
