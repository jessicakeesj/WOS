extends ParallaxBackground

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var offsetLoc =0
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	
func _process(delta):
	offsetLoc = offsetLoc - 150 * delta
	set_scroll_offset(Vector2(offsetLoc,0))

func set_bg(path):
	var bg_image = load("path")
	get_node("ParallaxLayer/Background").set_texture(bg_image)