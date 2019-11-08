extends Node2D

var section_array =[]
var section_name
var level_array =[]

var section_index =0

# How many times test loops are ran. Higher is slower, but gives better average.
const ITERATIONS = 1

onready var http =get_node("HTTPRequest")
onready var level_selection = get_node("LevelSelection")
onready var npc_dialogue = get_node("Dialogue")

var Firebase=load("res://firebase/Firebase.gd").new()

func _ready():
	Global.start_test("Level Selection (LevelSelection.tscn)")
	for i in range(0,ITERATIONS):
		Firebase.get_document_or_collection("Worlds", http)
		get_node("LevelSelection").disable_left_btn()
	pass # Replace with function body.


func display_loading():
	get_node("LevelSelection/SectionName").set_text("Loading...")
func _on_LevelSelection_left_clicked():
	display_loading()
	get_node("LevelSelection").enable_right_btn()
	section_index-=1
	if section_index  == 0:
		get_node("LevelSelection").disable_left_btn()
	else:
		get_node("LevelSelection").enable_left_btn()
	level_selection.disable_all_levels()
	Global.set_current_section(section_array[section_index])
	fetch_db("Section")


func _on_LevelSelection_right_clicked():
	display_loading()
	get_node("LevelSelection").enable_left_btn()
	section_index+=1
	if section_index  == section_array.size()-1:
		get_node("LevelSelection").disable_right_btn()
	else:
		get_node("LevelSelection").enable_right_btn()
	level_selection.disable_all_levels()
	Global.set_current_section(section_array[section_index])
	fetch_db("Section")

func display_section():
	var count =1
	get_node("LevelSelection/SectionName").set_text(section_name)
	for section in level_array:
		level_selection.display_levels(count)
		count+=1
	count =1
		

func fetch_section(request_result):
	for document in request_result:
		if(int(document.fields.Id.integerValue) == Global.get_current_world()):
			for section in document.fields.Sections.arrayValue.values:
				var sec = (section.mapValue.fields.Section.referenceValue)
				section_array.append(Global.get_truncated_ref(sec))
				
	Global.set_current_section(section_array[0])
	fetch_db("Section")


func fetch_level(request_result):
	level_array =[]
	for document in request_result:	
		if section_array[section_index] == Global.get_truncated_ref(document.name):
			section_name = document.fields.SectionName.stringValue
			for level in document.fields.Levels.arrayValue.values:
				level_array.append(Global.get_truncated_ref(level.referenceValue))
	display_section()
	fetch_db("Users")

#Display tutorial dialogue 
func display_level_tutorial():
	 npc_dialogue.show()
	 npc_dialogue.set_file(Global.get_level_tut())
	 npc_dialogue.display_dialogue()

func fetch_user_history(request_result):
	var count = 1
	var da = 1
	var unlock_next = true
	for document in request_result:
		if document.fields.UID.stringValue == Global.get_user_id():
			if document.fields.CompletedTutorial.booleanValue == false:
				display_level_tutorial()
			if document.fields.QuizHistory.arrayValue.size()>0:
				for quiz in document.fields.QuizHistory.arrayValue.values:
					if Global.get_truncated_ref(quiz.mapValue.fields.section.referenceValue) == section_array[section_index]:
						var level = quiz.mapValue.fields.level.integerValue
						var total_score = int(quiz.mapValue.fields.totalScore.integerValue)
						var max_score = int(quiz.mapValue.fields.maxScore.integerValue)
						level_selection.enable_level(level)
						level_selection.enable_level_icon(level)
						level_selection.display_stars(level, total_score, max_score)
						count+=1
						var percent = float(total_score)/float(max_score)*100
						if percent == 0:
							unlock_next = false
						else:
							unlock_next = true

	if unlock_next == true and count<=7:
		level_selection.enable_level(count)
		level_selection.enable_level_icon(count)
	#Lvl 1 will always be unlocked
	level_selection.enable_level(1)
	level_selection.enable_level_icon(1)
	get_node("LoadingScreen").set_visible(false)
	Global.stop_test(ITERATIONS)

func fetch_db(name):
	http =get_node("HTTPRequest")
	Firebase.get_document_or_collection(name, http)
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var request_result := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	
	if "Worlds" in request_result.documents[0].name:
		fetch_section(request_result.documents)
	elif "Section" in request_result.documents[0].name:
		fetch_level(request_result.documents)
	elif "Users" in request_result.documents[0].name:
		fetch_user_history(request_result.documents)
