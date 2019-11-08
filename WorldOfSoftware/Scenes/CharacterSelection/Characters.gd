extends Node2D

onready var char1 = get_node("Char1Area2D/Char1")
onready var char2 = get_node("Char2Area2D/Char2")

#test
func _ready():
	pass # Replace with function body.

func change_scene():
	yield(get_tree().create_timer(1.2), "timeout")
	get_tree().change_scene("res://Scenes/Worlds/WorldsScreen.tscn")
	#get_tree().change_scene("res://Scenes/Worlds/LevelSelection.tscn")

func _on_Char1Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			char1.play("jump")
			get_node("Char2Area2D/Char2Collison").disabled = true
			change_scene()
			
func _on_Char2Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			char2.play("jump")
			get_node("Char1Area2D/Char1Collision").disabled = true
			change_scene()
