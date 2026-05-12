extends Sprite2D

# Drag and drop your background images into the Inspector array
@export var background_textures: Array[Texture2D]

func _ready():
	if background_textures.size() > 0:
		# Selects a random texture from the list
		texture = background_textures.pick_random()
	else:
		push_warning("No textures added to the background list!")
