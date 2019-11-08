extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_create_assignment__pressed():
	get_tree().change_scene("res://Scenes/Assignments/Assignment.tscn")
	pass # Replace with function body.


func _on_edit_assignment__pressed():   
	get_tree().change_scene("res://Scenes/Assignments/Assignment.tscn")
	pass # Replace with function body. 


func _on_view_assignment_pressed():
	get_tree().change_scene("res://Scenes/Assignments/QuestionBank.tscn")
	pass # Replace with function body.


func _on_BackButton_pressed():
	pass # Replace with function body.
