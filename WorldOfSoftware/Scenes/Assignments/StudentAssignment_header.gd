extends Control

onready var http : HTTPRequest = $HTTPRequest
var Firebase=load("res://firebase/Firebase.gd").new()
var student_ans = []
var real_ans =[]
var total_score = 0;

func _ready()->void:
	get_answer_key()

func _on_ans_input_text_changed(new_text):
	student_ans.append(int(new_text))
	
	print(student_ans)

func points_scored():
	for points in student_ans:
		if (points in student_ans) and (points in real_ans):
			total_score +=1
	print(total_score)

func get_formated_questionset(documents: Array) -> void:
	for document in documents:
		var split := document.name.split("/") as PoolStringArray
		var questionset = {
			"Answer": int(document.fields.Answer.integerValue),
			#"id": split[split.size() - 1]
		}
		print(questionset.Answer)
		real_ans.append(questionset.Answer)
		print(real_ans)

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Assignments/AssignmentMenu.tscn")

func get_answer_key() -> void:
	Firebase.get_document_or_collection("Assignment", http)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var request_result := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	if "documents" in request_result.keys():
		var questionset := get_formated_questionset(request_result.documents)

