extends CanvasLayer

signal finished

@onready var video: VideoStreamPlayer = $VideoStreamPlayer

func play() -> void:
	video.set_anchors_preset(Control.PRESET_FULL_RECT)
	video.expand = true
	video.offset_left   = 0
	video.offset_top    = 0
	video.offset_right  = 0
	video.offset_bottom = 0
	video.play()
	await _wait_for_video_end()
	emit_signal("finished")

func _wait_for_video_end() -> void:
	while video.is_playing():
		await get_tree().process_frame
