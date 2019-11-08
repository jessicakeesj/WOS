extends Control


func _on_RegisterButton_pressed() -> void:
	get_tree().change_scene("res://Scenes/Register/Register.tscn")


func _on_LoginButton_pressed() -> void:
	get_tree().change_scene("res://Scenes/Login/Login.tscn")
