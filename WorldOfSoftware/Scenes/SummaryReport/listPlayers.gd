extends Node

onready var http : HTTPRequest = $HTTPRequest
var Firebase = load("res://firebase/Firebase.gd").new()
onready var globals = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

func fetch_from_db(path):
	Firebase.get_document_or_collection(path, http)

func _on_Class_pressed():
	globals.select_student =  get_node('StudentName').text
	globals.select_user_email = get_node('UID').text
	fetch_from_db("Users")
	yield(get_tree().create_timer(2.0), "timeout")
	

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	for students in json.result["documents"]:
		if(students.fields.has('Name')):
			if(students.fields.has('UID')):
				if(students.fields['Name'].values()[0] == globals.select_student):
					if(students.fields['UID'].values()[0] == globals.select_user_email):
						globals.select_user_id = str(students.fields["UID"].values()[0])
						get_tree().change_scene("res://Scenes/SummaryReport/StudentReport.tscn")
