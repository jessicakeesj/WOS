extends Control

onready var http : HTTPRequest = $HTTPRequest
onready var question : Label = $Panel/MenuBG/ScrollContainer/VBoxContainer/question
onready var option_one : Label = $Panel/MenuBG/ScrollContainer/VBoxContainer/op1
onready var option_two : Label = $Panel/MenuBG/ScrollContainer/VBoxContainer/op2
onready var option_three : Label = $Panel/MenuBG/ScrollContainer/VBoxContainer/op3
onready var option_four : Label = $Panel/MenuBG/ScrollContainer/VBoxContainer/op4
onready var answer : LineEdit = $VBoxContainer/answer
onready var column : VBoxContainer = $Panel/MenuBG/ScrollContainer/VBoxContainer
onready var notification : Label = $Notification

var question_counter = 1

const ListItem=preload("res://Scenes/Assignments/StudentAssignment_header.tscn")

var Firebase=load("res://firebase/Firebase.gd").new()

func _ready()->void:
	get_assignment_questions()

var ans_key = []
var student_ans = []
var total_score = 0

func get_formated_questionset(documents: Array) -> void:
	for document in documents:
		var split := document.name.split("/") as PoolStringArray
		var questionset = {
			"Question":document.fields.Question.stringValue,
			"Option1":document.fields.Option1.stringValue,
			"Option2":document.fields.Option2.stringValue,
			"Option3":document.fields.Option3.stringValue,
			"Option4":document.fields.Option4.stringValue,
			"Answer": int(document.fields.Answer.integerValue),
			"QuestionID": int( document.fields.Question_ID.integerValue),
			#"id": split[split.size() - 1]
		}
		print(questionset.Answer)
		ans_key.append(questionset.Answer)
		print(ans_key)
		addItem(questionset)
		question_counter+=1

func addItem(value):
	var item=ListItem.instance()
	item.get_node("VBoxContainer/question").text="Question %d: " %question_counter + value.Question 
	item.get_node("VBoxContainer/op1").text="Option 1: "+value.Option1
	item.get_node("VBoxContainer/op2").text="Option 2: "+value.Option2
	item.get_node("VBoxContainer/op3").text="Option 3: "+value.Option3
	item.get_node("VBoxContainer/op4").text="Option 4: "+value.Option4
	item.rect_min_size=Vector2(547,450)
	$Panel/MenuBG/ScrollContainer/VBoxContainer.add_child(item)

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Worlds/WorldsScreen.tscn")

func get_assignment_questions() -> void:
	Firebase.get_document_or_collection("Assignment", http)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var request_result := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	if "documents" in request_result.keys():
		var questionset := get_formated_questionset(request_result.documents)
		#print(questionset)

func _on_LineEdit_text_entered(new_text):
	student_ans.append(int(new_text))
	print(student_ans)


func _on_Submit_pressed():
	for points in student_ans.size():
		if student_ans[points] == ans_key[points]:
			
			total_score += 1
			print("Truee")
		else:
			print("False")
	
		print(total_score)
	notification.text = "You scored %d points!"%total_score
