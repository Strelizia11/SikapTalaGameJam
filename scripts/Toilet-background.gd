extends Sprite2D
 
# Drag and drop your background images into the Inspector array
@export var background_textures: Array[Texture2D]
 
func _ready():
	var path = GlobalBackground.current_bg_path2
	var music = GlobalBackground.bgm_path
	texture = load(path)
	AudioManager.play_bgm(load(music))
 
