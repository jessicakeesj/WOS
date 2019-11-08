extends Node2D


onready var char_preview = get_node("CharPreview")
onready var char_name = get_node("CharName")
onready var char_selected = "Cat"

onready var http =get_node("HTTPRequest")
var Firebase=load("res://firebase/Firebase.gd").new()

var user_data := {
		"Email": {},
		"Domain": {},
		"Name": {},
		"Class": {},
		"UID": {},
		"UserSprite": {}
	}
var data_fetched = false
func _ready():
	Firebase.get_document_or_collection("Users", http)


func change_scene():
	Global.alt_animation(char_preview, char_selected)
	yield(get_tree().create_timer(1.8), "timeout")
	get_tree().change_scene("res://Scenes/Worlds/WorldsScreen.tscn")

func _on_CatArea_input_event(viewport, event, shape_idx):
	if event.is_pressed():
			Global.run_animation(char_preview, "Cat")
			char_selected = "Cat"
			char_name.set_text(char_selected)

func _on_DogArea_input_event(viewport, event, shape_idx):
	if event.is_pressed():
			Global.run_animation(char_preview, "Dog")
			char_selected = "Dog"
			char_name.set_text(char_selected)


func _on_JackArea_input_event(viewport, event, shape_idx):
	if event.is_pressed():
			Global.run_animation(char_preview, "Jack")
			char_selected = "Jack"
			char_name.set_text(char_selected)


func _on_RobotArea_input_event(viewport, event, shape_idx):
	if event.is_pressed():
			Global.run_animation(char_preview, "Robot")
			char_selected = "Robot"
			char_name.set_text(char_selected)


func _on_ZombieMArea_input_event(viewport, event, shape_idx):
	if event.is_pressed():
			Global.run_animation(char_preview, "ZombieM")
			char_selected = "ZombieM"
			char_name.set_text(char_selected)


func _on_ZombieFArea_input_event(viewport, event, shape_idx):
	if event.is_pressed():
			Global.run_animation(char_preview, "ZombieF")
			char_selected = "ZombieF"
			char_name.set_text(char_selected)


func _on_NinjaArea_input_event(viewport, event, shape_idx):
	if event.is_pressed():
			Global.run_animation(char_preview, "Ninja")
			char_selected = "Ninja"
			char_name.set_text(char_selected)


func _on_BoxArea_input_event(viewport, event, shape_idx):
	if event.is_pressed():
			Global.run_animation(char_preview, "Box")
			char_selected = "Box"
			char_name.set_text("BoxHead")


func _on_BtnArea_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		disable_user_input()
		save_sprite()
		Global.set_selected_character(char_selected)
		change_scene()

func fetch_user_history(request_result):
	#Global.set_user_id("VQlmW6OaPaT4NJTrVzv7H2ejo2g2")
	#Global.set_user_id("y4vhvl5smZYWk60HmIes")

	for document in request_result:
		if document.fields.UID.stringValue == Global.get_user_id():
			var user_key = Global.get_truncated_ref(document.name)
			Global.set_user_key(user_key)
		#	print(Global.get_user_key())
			user_data.Email = {"stringValue" : document.fields.Email.stringValue}
			#user_data.Password = {"stringValue" : document.fields.Password.stringValue}
			user_data.Domain = {"stringValue" : document.fields.Domain.stringValue}
			user_data.Name = {"stringValue" : document.fields.Name.stringValue}
			user_data.Class = {"stringValue" : document.fields.Class.stringValue}
			user_data.UID ={"stringValue" : document.fields.UID.stringValue}
			user_data.CompletedTutorial = {"booleanValue": document.fields.CompletedTutorial.booleanValue}
			user_data.CompletedWorlds = {"arrayValue":{}}
			user_data.QuizHistory = {"arrayValue":{}}
		#if(document != null):
			if document.fields.UserSprite.stringValue != "":
			#if Global.get_user_id() == " ":
				Global.set_selected_character(document.fields.UserSprite.stringValue)
				get_tree().change_scene("res://Scenes/Worlds/WorldsScreen.tscn")
			else:
				get_node("LoadingScreen").set_visible(false)
			break
	data_fetched = true


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var request_result := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	var json = JSON.parse(body.get_string_from_utf8())

	if data_fetched == false:
		fetch_user_history(request_result.documents)
	print(response_code)
func save_sprite():
	var path = "Users/%s" % str(Global.get_user_key())
	#path = path + str(Global.get_user_key())
	print(path)
	print(char_selected)
	print(user_data)
	user_data.UserSprite = {"stringValue" : char_selected}
	
	
	Firebase.update_document(path, user_data, http)

func disable_user_input():
	get_node("BtnArea/CollisionShape2D").set_disabled(false)
	
	var characters = get_node("Characters")
	for node in characters.get_children():
		if node is Area2D:
			for node2 in node.get_children():
				if node2 is CollisionShape2D:
					node2.set_disabled(true)
