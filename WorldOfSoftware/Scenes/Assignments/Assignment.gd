extends Control

var Firebase=load("res://firebase/Firebase.gd").new()
onready var http : HTTPRequest = $HTTPRequest
onready var add_question_button : Button = $HBoxContainer/AddQuestion
onready var question : TextEdit = $VBoxContainer/question_box
onready var option_one : LineEdit = $VBoxContainer/op1
onready var option_two : LineEdit = $VBoxContainer/op2
onready var option_three : LineEdit = $VBoxContainer/op3
onready var option_four : LineEdit = $VBoxContainer/op4
onready var answer : LineEdit = $VBoxContainer/answer
onready var notification : Label = $Notification

var question_counter := 8
var ans

func _ready():
    connect("text_entered", self, "_on_text_entered")

func _on_AddQuestion_pressed() -> void:
	var body := {
		"Question": {"stringValue": question.text },
		"Option1": {"stringValue": option_one.text },
		"Option2": {"stringValue": option_two.text },
		"Option3": {"stringValue": option_three.text },
		"Option4": {"stringValue": option_four.text },
		"Answer": {"integerValue": answer},
		"Question_ID":{"integerValue": question_counter },
	}
	Firebase.save_document("Assignment", body, http) 
	question_counter += 1
	
func _on_Finish_pressed():
	get_tree().change_scene("res://Scenes/Assignments/GiveAssignment.tscn")

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Assignments/AssignmentMenu.tscn")
	
func _on_QuestionBankBtn_pressed():
	get_tree().change_scene("res://Scenes/Assignments/QuestionBank.tscn")

func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	#var request_result := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	add_question_button.disabled = false
	notification.text = "Question %d has been completed\n Enter the details for %d" %[question_counter, question_counter+1]
	print("Sent Assignment Questions to data base")

func _on_answer_text_changed(new_text):
	if new_text == "1":
		ans = 1
		print(ans)
	elif new_text == "2":
		ans = 2
		print(ans)
	elif new_text == "3":
		ans = 3
		print(ans)
	elif new_text == "4":
		ans = 4
		print(ans)
