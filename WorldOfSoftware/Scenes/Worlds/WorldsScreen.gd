extends Node2D

onready var npc_dialogue = get_node("Dialogue")
onready var http =get_node("HTTPRequest")
var Firebase=load("res://firebase/Firebase.gd").new()
var world_data =[]

func _ready():
	 #display_world()
	Firebase.get_document_or_collection("Users", http)

func redirect_level(index):
	Global.set_current_world(index)
	get_tree().change_scene("res://Scenes//Worlds//LevelSelection.tscn")

	

#Display tutorial dialogue 
func display_world_tutorial():
	 npc_dialogue.show()
	 npc_dialogue.set_file(Global.get_world_tut())
	 npc_dialogue.display_dialogue()

func fetch_user_history(request_result):
	var count = 1
	for document in request_result:
		if document.fields.UID.stringValue == Global.get_user_id():
			if document.fields.CompletedTutorial.booleanValue == false:
				display_world_tutorial()
			print(document.fields.UID.stringValue)
			if document.fields.CompletedWorlds.arrayValue.size()>0:
				for world in document.fields.CompletedWorlds.arrayValue.values:
					world_data.append(world.referenceValue)
			break
	var index =1
	for world in world_data:
		if index > 1:
			var path = "Bg/World%s" % index
			get_node(path).modulate = Color(1, 1, 1, 1)
			var path_2 = path + "/Area2D/CollisionShape2D"
			get_node(path_2).disabled = false
			print(path)
		index+=1
	get_node("LoadingScreen").hide()


func fetch_db(name):
	http =get_node("HTTPRequest")
	Firebase.get_document_or_collection(name, http)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var request_result := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	fetch_user_history(request_result.documents)
	pass # Replace with function body.


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		redirect_level(1)


func _on_Area2DWorld2_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		redirect_level(2)
		#get_tree().change_scene("res://Scenes//Worlds//World1//World1Levels.tscn")


func _on_Area2DWorld3_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		redirect_level(3)

func _on_Area2DWorld4_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		redirect_level(4)
