extends Sprite2D

# Drag and drop your background images into the Inspector array
@export var background_textures: Array[Texture2D]

func _ready():
	var path = GlobalBackground.current_bg_path2
	texture = load(path)
