extends Panel


onready var selectedClass = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ClassName_pressed():
	selectedClass.select_class =  get_node('ClassName').text
	get_tree().change_scene("res://Scenes/SummaryReport/StudentNames.tscn")
