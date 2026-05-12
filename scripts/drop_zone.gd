extends Area2D

func _ready():
	add_to_group("drop_zone")
	$Visual.visible = false

func show_zone():
	pass

func hide_zone():
	$Visual.visible = false

func set_hovering(_is_hovering: bool):
	pass
