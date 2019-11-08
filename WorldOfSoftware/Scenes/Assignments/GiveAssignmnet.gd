extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Assignments/Assignment.tscn")

func _on_FBButton_pressed():
	OS.shell_open("https://www.facebook.com/groups/413176259616810/")
	pass # Replace with function body.

func _on_TwitButton_pressed():
	OS.shell_open("https://twitter.com/home")
	pass # Replace with function body.

