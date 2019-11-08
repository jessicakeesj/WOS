extends Control

export (NodePath) var checkBox
onready var check = get_node(checkBox)

func _ready():
	pass 

func _on_CheckBox_toggled(button_pressed):
	if button_pressed == true:
		Global.challenges.append(str(check.text))
	else:
		if(Global.challenges.has(str(check.text))):
			Global.challenges.remove(str(check.text))
	pass # Replace with function body.
