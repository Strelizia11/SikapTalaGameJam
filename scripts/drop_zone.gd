extends Area2D

func _ready():
	add_to_group("drop_zone")
	# Visual is always hidden — drop zone is invisible to player
	$Visual.visible = false

func show_zone():
	# No visual shown — zone is invisible but still works
	pass

func hide_zone():
	$Visual.visible = false

func set_hovering(_is_hovering: bool):
	# No visual feedback — zone is completely invisible
	pass
