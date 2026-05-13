extends CanvasLayer

signal finished

@onready var video: VideoStreamPlayer = $VideoStreamPlayer

func play() -> void:
	# Stream is already assigned in the Inspector, just play it
	video.play()

	await _wait_for_video_end()

	emit_signal("finished")

func _wait_for_video_end() -> void:
	while video.is_playing():
		await get_tree().process_frame
