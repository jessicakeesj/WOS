  
extends Control

onready var http : HTTPRequest = $HTTPRequest
onready var question : Label = $Panel/MenuBG/ScrollContainer/VBoxContainer/question
onready var option_one : Label = $Panel/MenuBG/ScrollContainer/VBoxContainer/op1
onready var option_two : Label = $Panel/MenuBG/ScrollContainer/VBoxContainer/op2
onready var option_three : Label = $Panel/MenuBG/ScrollContainer/VBoxContainer/op3
onready var option_four : Label = $Panel/MenuBG/ScrollContainer/VBoxContainer/op4
onready var answer : LineEdit = $VBoxContainer/answer
onready var column : VBoxContainer = $Panel/MenuBG/ScrollContainer/VBoxContainer
onready var edit_button : Button = $Edit_Button

export var score_row : PackedScene
var question_counter = 1

const ListItem=preload("res://Scenes/Assignments/Question_headers.tscn")
var Firebase=load("res://firebase/Firebase.gd").new()

func _ready()->void:
	get_assignment_questions()

func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var request_result := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	if "documents" in request_result.keys():
		var questionset := get_formated_questionset(request_result.documents)
		#print(questionset)

func get_formated_questionset(documents: Array) -> void:
	for document in documents:
#		print(document.fields)
		#var split := document.name.split("/") as PoolStringArray
		var questionset = {
			"Question":document.fields.Question.stringValue,
			"Option1":document.fields.Option1.stringValue,
			"Option2":document.fields.Option2.stringValue,
			"Option3":document.fields.Option3.stringValue,
			"Option4":document.fields.Option4.stringValue,
		}
		print(questionset)
		addItem(questionset)
		question_counter+=1

func addItem(value):
#	print(value.Question)
	var item=ListItem.instance()
	item.get_node("VBoxContainer/question").text="Question %d: " %question_counter + value.Question 
	item.get_node("VBoxContainer/op1").text="Option 1: "+value.Option1
	item.get_node("VBoxContainer/op2").text="Option 2: "+value.Option2
	item.get_node("VBoxContainer/op3").text="Option 3: "+value.Option3
	item.get_node("VBoxContainer/op4").text="Option 4: "+value.Option4
	item.rect_min_size=Vector2(547,400)
	$Panel/MenuBG/ScrollContainer/VBoxContainer.add_child(item)

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Assignments/AssignmentMenu.tscn")

func get_assignment_questions() -> void:
	Firebase.get_document_or_collection("Assignment", http)