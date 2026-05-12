extends Control

@onready var transition_player = $Transition/Transitions/AnimationPlayer
@onready var overlay = $Transition/Transitions/ColorRect

# The lock to prevent clicking while transitioning
var is_transitioning = false

func _ready():
	transition_player.play("black_to_fade")
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	await transition_player.animation_finished
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
