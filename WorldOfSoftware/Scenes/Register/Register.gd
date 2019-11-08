# Aung 
# Last Edited 8/11
extends Control
const ClassName = preload("res://static/Firebase.gd")
var Firebase = ClassName.new()

# Yongxin's firebase file
var Firebase2 = load("res://firebase/Firebase.gd").new()
# Aung Email sending Firebase file 
var verifyBase = load("res://Scenes/Login/Confimation.gd").new()

onready var http : HTTPRequest = $HTTPRequest
onready var http2 : HTTPRequest = $HTTPRequest2
onready var http3 : HTTPRequest = $HTTPRequest3
onready var http4 : HTTPRequest = $HTTPRequest4
onready var username : LineEdit = $VBoxContainer/Username/LineEdit
onready var password : LineEdit = $VBoxContainer/Password/LineEdit
onready var confirm : LineEdit = $VBoxContainer/Password/LineEdit
onready var notification : Label = $Notification
onready var name1 : LineEdit = $VBoxContainer/Name/LineEdit
onready var domain2 : OptionButton = $VBoxContainer/Domain2/LineEdit
onready var class_ : OptionButton = $VBoxContainer/Class/LineEdit

func _on_RegisterButton_pressed() -> void:
	if password.text != confirm.text or username.text.empty() or password.text.empty():
		notification.text = "Invalid password or username"
		return
	print("fsfdf")
	#var returnVar = "%s.%s" 
	#var finalVar = returnVar % [domain.text.to_upper(),username.text]
	Firebase.register(username.text, password.text, http)


func _on_BackButton_pressed() -> void:
	print(domain2.get_item_text(domain2.get_index()))
	get_tree().change_scene("res://Scenes/Home/Main.tscn")

func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var response_body := JSON.parse(body.get_string_from_ascii())
	if response_code != 200:
		notification.text = response_body.result.error.message.capitalize()
	else:
		Firebase2.get_document_or_collection("Users", http2)
		yield(http2,"request_completed")
		notification.text = "Registration sucessful! Check your email to verify."
		yield(get_tree().create_timer(2.0), "timeout")
		verifyBase.sendRegMail(Firebase.user_info.token, http4)
		#yield(http,"request_completed")
		print(Firebase.user_info.id)
		
		

func _on_HTTPRequest2_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	print("Temporary Solution")
	var emptyarr:=[]
	var infos:={
			"Email" : {"stringValue": username.text},
			#"Password" : {"stringValue":password.text},
			"Domain" : {"stringValue":domain2.get_item_text(domain2.get_selected_id())},
			"Name" : {"stringValue":name1.text},
			"Class" : {"stringValue":class_.get_item_text(class_.get_selected_id())},
			"UID" : {"stringValue":Firebase.user_info.id},
			"CompletedTutorial" : {"booleanValue": "False"},
			"CompletedWorlds":{"arrayValue":{}},
			"UserSprite": {"stringValue": ""},
			"QuizHistory" : {"arrayValue": {}},
			"ChallengeHistory" : {"arrayValue": {}}
			
		}
	print(infos)
	#Firebase2.save_document("Users", infos, http3)
	Firebase.save_document("Users?documentId=%s" % Firebase.user_info.id, infos, http3)
	
# Buffer HTTPRequests
func _on_HTTPRequest3_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	print("added to database")
	
func _on_HTTPRequest4_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	print("req4 done")
	get_tree().change_scene("res://Scenes/Login/Login.tscn")