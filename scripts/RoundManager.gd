extends Node

var _reveal_used: bool = false

func can_use_reveal() -> bool:
	return not _reveal_used

func use_reveal() -> void:
	_reveal_used = true

# call when a new round/correct answer happens
func reset_round() -> void:
	_reveal_used = false

# call when game fully resets
func reset_game() -> void:
	_reveal_used = false
