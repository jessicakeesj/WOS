extends Control

var Firebase=load("res://firebase/Firebase.gd").new()
onready var http : HTTPRequest = $HTTPRequest
onready var add_question_button : Button = $HBoxContainer/AddQuestion
onready var question : TextEdit = $VBoxContainer/question_box
onready var option_one : LineEdit = $LineEdit1
onready var option_two : LineEdit = $LineEdit2
onready var option_three : LineEdit = $LineEdit3
onready var option_four : LineEdit = $LineEdit4
onready var answer : LineEdit = $VBoxContainer/answer
onready var notification : Label = $Notification

var editing_ID = 0

func _ready():
	pass # Replace with function body.

func _on_create_assignment__pressed():
	get_tree().change_scene("res://Scenes/Assignments/Assignment.tscn")

func _on_edit_assignment__pressed():
	get_tree().change_scene("res://Scenes/Assignments/QuestionBank.tscn")

func _on_view_assignment_pressed():
	get_tree().change_scene("res://Scenes/Assignments/QuestionBank.tscn")

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Assignments/AssignmentMenu.tscn")

func _on_numberSelect_text_changed(new_text):
	var numbers = []
	for x in range(21):
		numbers.append("%d" %x)

	if int(new_text) > 20:
		notification.text = "Out of Range, please try again!"
	elif new_text <= "0":
		notification.text = "Out of Range, please try again!"
	else:
		notification.text = "Please wait..."
		get_tree().change_scene("res://Scenes/Assignments/EditAssignment2.tscn")
	editing_ID = int(new_text)
	
	get_assignment_questions()

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var request_result := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	if "documents" in request_result.keys():
		var ID := get_formated_questionset(request_result.documents)
		#print(questionset)

func get_formated_questionset(documents: Array) -> void:
	for document in documents:
		var ID = {
			"Question":document.fields.Question.stringValue,
			"Option1":document.fields.Option1.stringValue,
			"Option2":document.fields.Option2.stringValue,
			"Option3":document.fields.Option3.stringValue,
			"Option4":document.fields.Option4.stringValue,
			"Answer":int(document.fields.Answer.integerValue),
			"Question_ID":int(document.fields.Question_ID.integerValue),
			"id": split[split.size() - 1]
		}
		print(ID)
		if ID.Quesion_ID == int(editing_ID):
			addItem(ID)

func addItem(value):
	get_node("question").text=value.Question 
	get_node("op1").text=value.Option1
	get_node("op2").text=value.Option2
	get_node("op3").text=value.Option3
	get_node("op4").text=value.Option4
	get_node("op4").text=value.Option4
	get_node("Asnwer").text=value.Answer

func _on_UpdateButton_pressed():
	var body := {
		"Question": {"stringValue": question.text },
		"Option1": {"stringValue": option_one.text },
		"Option2": {"stringValue": option_two.text },
		"Option3": {"stringValue": option_three.text },
		"Option4": {"stringValue": option_four.text },
		"Answer": {"integerValue": ans},
		"Question_ID":{"integerValue": question_counter },
	}
	Firebase.update_document("Assignment/%s"%"document", body, http) 

func get_assignment_questions() -> void:
	Firebase.get_document_or_collection("Assignment", http)


