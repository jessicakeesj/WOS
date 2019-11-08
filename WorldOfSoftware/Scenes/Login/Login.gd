# Aung 
# Last Edited 8/11
extends Control
const ClassName = preload("res://static/Firebase.gd")
var Firebase = ClassName.new()
var Firebase2 = load("res://firebase/Firebase.gd").new()

onready var http : HTTPRequest = $HTTPRequest
onready var http2 = get_node("HTTPRequest2")
onready var http3 : HTTPRequest = $HTTPRequest3
onready var http4 : HTTPRequest = $HTTPRequest4
onready var http5 : HTTPRequest = $HTTPRequest5
onready var username : LineEdit = $VBoxContainer/Username/LineEdit
onready var password : LineEdit = $VBoxContainer/Password/LineEdit
onready var notification : Label = $Notification

onready var domain2 : OptionButton = $VBoxContainer/Domain/LineEdit
var domainText = ""
var userID:= ""
var isVerified := false

func _on_LoginButton_pressed() -> void:
	# set domaintext
	domainText = str(domain2.get_item_text(domain2.get_selected_id()))
	if username.text.empty() or password.text.empty():
		# empty username/pass
		notification.text = "Enter Username or Password"
		return
	Firebase.login(username.text, password.text, http)


func _on_BackButton_pressed() -> void:
	get_tree().change_scene("res://Scenes/Home/Main.tscn")
	
func get_format_users(documents: Array)-> Array:
	# return array of documents. might not be using in final version.
	var users:=[]
	for document in documents:
		users.append(document)
	return users


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var response_body := JSON.parse(body.get_string_from_ascii())
	if response_code != 200:
		# failed login
		notification.text = response_body.result.error.message.capitalize()
	else:
		#Firebase2.get_document_or_collection("Users", http2)
		Firebase2.get_document_or_collection("Users", http2)
		yield(http,"request_completed")
		#userID = Firebase.user_info.id
		#print(userID)

func _on_HTTPRequest2_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void: 
	print("HTTP2 Done")
	print(Firebase.user_info.token)
	Firebase.check_verify(Firebase.user_info.token, http5)

# Buffer request
func _on_HTTPRequest5_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void: 
	print("HTTP5 Done")
	Firebase2.get_document_or_collection("Users", http3)

# Check if verified email
func _on_HTTPRequest3_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void: 
	print("HTTP3 Done")
	if Firebase.isVerified:
		Firebase.get_document("Users/%s" % Firebase.user_info.id,http4)
	else:
		notification.text = "Please Verify Your Email"

# Check domain and redirect
func _on_HTTPRequest4_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	print(Firebase.isVerified)
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	print("body is")
	print(result_body.fields.Domain)
	if "STUDENT" in domainText and "STUDENT" in str(result_body.fields.Domain):
		notification.text = "Student Login sucessful!"
		userID = Firebase.user_info.id
		yield(get_tree().create_timer(2.0), "timeout")
		#yield(http,"request_completed")
		Global.set_user_id(userID)
		Global.set_user_key(userID)
		Global.set_selected_character(result_body.fields.UserSprite)
	
		get_tree().change_scene("res://Scenes/CharacterSelection/CharacterSelection.tscn")
	elif "TEACHER" in domainText and "TEACHER" in str(result_body.fields.Domain):
		notification.text = "Teacher Login sucessful!"
		userID = Firebase.user_info.id
		Global.set_user_id(userID)
		yield(get_tree().create_timer(2.0), "timeout")
		#yield(http,"request_completed")
		get_tree().change_scene("res://Scenes/SummaryReport/Summary.tscn")
	else:
		notification.text = "You chose the wrong domain."
	print("User ID is")
	print(userID)
			
func get_userid() -> String:
	# call this to get user ID
	return userID
