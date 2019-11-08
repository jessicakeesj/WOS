extends Node2D

export (NodePath) var questionTextPath
export (NodePath) var optionBtn1
export (NodePath) var optionBtn2
export (NodePath) var optionBtn3
export (NodePath) var optionBtn4
export (NodePath) var optionLabel1
export (NodePath) var optionLabel2
export (NodePath) var optionLabel3
export (NodePath) var optionLabel4
export (NodePath) var background
export (NodePath) var popupDialog
export (NodePath) var popupLabel
export (NodePath) var popupLabelDesc
export (NodePath) var scoreLabel
export (NodePath) var popupButton
export (NodePath) var popupButtonTxt
export (NodePath) var backButton

onready var questionText = get_node(questionTextPath)
onready var option1 = get_node(optionBtn1)
onready var option2 = get_node(optionBtn2)
onready var option3 = get_node(optionBtn3)
onready var option4 = get_node(optionBtn4)
onready var optionTxt1 = get_node(optionLabel1)
onready var optionTxt2 = get_node(optionLabel2)
onready var optionTxt3 = get_node(optionLabel3)
onready var optionTxt4 = get_node(optionLabel4)
onready var worldBG = get_node(background)
onready var popup = get_node(popupDialog)
onready var popupTxt = get_node(popupLabel)
onready var popupTxtDesc = get_node(popupLabelDesc)
onready var popupBtn = get_node(popupButton)
onready var popupBtnTxt = get_node(popupButtonTxt)
onready var scoreTxt = get_node(scoreLabel)
onready var backBtn = get_node(backButton)

onready var http : HTTPRequest = $HTTPRequest
var Firebase = load("res://firebase/Firebase.gd").new()

var assets_path = "res://Assets//Quiz//"
var font_path = "res://Fonts//"
var world_bg
var options_normal
var options_clicked
var options_correct
var dialog
var dialog_bg
var selected_character

var current_user
var current_world
var current_section
var current_level
var current_domain
var current_name
var current_uid
var current_class
var questions = {}
var totalScore = 0
var scoreObtained
var maxScore
var existing_complete
var finalSection 
var finalLevel

var timeDict = OS.get_datetime();
var day = timeDict.day;
var month = timeDict.month;
var year = timeDict.year;
var hour = timeDict.hour;
var minute = timeDict.minute;
var seconds = timeDict.second;
var existing_hist
var challenge_hist
var selection_arr = []
var history_arr = []
var question_keys = []

var current_question_key = "hHgqShTzku8hhR7X9XPf"
var current_answer

var end = false

signal response
signal ok

var sprite_node

func _ready():
	current_user = Global.user_key
	loadCharacter()
	initiate()
	popup_dialog("Loading..", "", false)
	fetch_from_db("Users/" + str(current_user)) # get history

func loadCharacter():
	var selected_char = Global.get_selected_character()
	var path = "/%s/%s" % [selected_char, selected_char]
	sprite_node = get_node("Character/AnimatedSprite")
	Global.add_frames(sprite_node, "%s%s" % [path, "_Idle/"], "idle", 8)
	Global.add_frames(sprite_node, "%s%s" % [path, "_Run/"], "run", 8)
	Global.add_frames(sprite_node, "%s%s" % [path, "_Jump/"], "jump", 8)
	Global.add_frames(sprite_node, "%s%s" % [path, "_Dead/"], "dead", 8)
	sprite_node.set_flip_h(true)
	sprite_node.frames.set_animation_loop("dead", false)
	sprite_node.play("idle")

func initiate():
	if int(day) < 10:
		day = '0'+str(day)
	if int(month) < 10:
		month = '0'+str(month)
	if int(hour) < 10:
		hour = '0'+str(hour)
	if int(minute) < 10:
		minute = '0'+str(minute)
	if int(seconds) < 10:
		seconds = '0'+str(seconds)
	# get player's current location
	current_world = Global.get_current_world()
	current_section = Global.get_current_section()
	current_level = Global.get_current_level()
	# resources path
	assets_path += "World//"
	world_bg = load(assets_path+"background.png")
	options_normal = load(assets_path+"button-normal.png")
	options_clicked = load(assets_path+"button-clicked.png")
	dialog = load(assets_path+"dialog_button.png")
	dialog_bg = load(assets_path+"Window.png")
	# set resources
	worldBG.texture = world_bg
	popup.set_normal_texture(dialog_bg)
	popupBtn.set_normal_texture(dialog)
	popupTxtDesc.add_color_override("font_color", Color(0,0,0))
	

# setup question, options
func setup_question(qns):
	current_question_key = qns["questionKey"]
	# set resources
	questionText.set_text(qns["question"])
	option1.set_normal_texture(options_normal)
	option2.set_normal_texture(options_normal)
	option3.set_normal_texture(options_normal)
	option4.set_normal_texture(options_normal)
	option1.hide()
	option2.hide()
	option3.hide()
	option4.hide()
	optionTxt1.set_text("")
	optionTxt2.set_text("")
	optionTxt3.set_text("")
	optionTxt4.set_text("")
	for i in qns["option"].size():
		match i:
			0: 
				optionTxt1.set_text(qns["option"][i]);
				option1.show();
			1: 
				optionTxt2.set_text(qns["option"][i]);
				option2.show();
			2: 
				optionTxt3.set_text(qns["option"][i]);
				option3.show();
			3: 
				optionTxt4.set_text(qns["option"][i]);
				option4.show();

# check selected answer and save selected answer
func check_answer(question_key, selected):
	if (questions[question_key]["answer"] == selected): # correct answer selected
		sprite_node.play("jump")
		scoreObtained = questions[question_key]["point"]
		popup_dialog("Correct!", questions[question_key]["explanation"], true)
	else: # wrong answer selected
		sprite_node.play("dead")
		scoreObtained = 0
		popup_dialog("Wrong!", questions[question_key]["explanation"], true)
	
	update_total_score()
	scoreTxt.set_text(str(totalScore))
	create_selection(current_question_key, selected, scoreObtained)
	emit_signal("response")

# update total score
func update_total_score():
	var total_score = 0
	totalScore += scoreObtained

# prompt dialog
func popup_dialog(text, description, showButton):
	popupTxt.set_text(text)
	popupTxtDesc.set_text(description)
	popup.show()
	popupTxt.show()
	popupTxtDesc.show()
	if showButton:
		popupBtn.show()
		popupBtnTxt.show()

func close_dialog():
	popupTxt.set_text("")
	popupTxtDesc.set_text("")
	popup.hide()
	popupTxt.hide()
	popupTxtDesc.hide()
	popupBtn.hide()
	popupBtnTxt.hide()
	if end == true:
		end_quiz()

func start_quiz():
	popup_dialog("Ready?", "", false)
	yield(get_tree().create_timer(3.0), "timeout")
	popupTxt.set_text("Start!")
	sprite_node.play("run")
	yield(get_tree().create_timer(0.5), "timeout")
	close_dialog()
	for qns in questions:
		setup_question(questions[qns])
		yield(self,"response")
	end = true

func end_quiz():
	popup_dialog("Your score is: %s" % totalScore, "", true)
	sprite_node.play("idle")
	create_history(totalScore, current_world, current_section, current_level, current_question_key)
	end = false;
	#get_tree().change_scene("res://Scenes//Worlds//LevelSelection.tscn")
#	get_tree().quit() # will quit game for now
		

func get_world_section_questions_db(result):
	# get question reference from world collection
	for i in result.fields.Sections.arrayValue.values:
		if i.mapValue.fields.has("Questions"):
			for questionRef in i.mapValue.fields.Questions.arrayValue.values:
				# get question key from reference
				var array = questionRef.referenceValue.rsplit("/", true, 0)
				var questionKey = array[array.size() - 1]
				question_keys.append(questionKey)
	# fetch the question from questions collection
	fetch_from_db("Questions")

func get_questions_db(result):
	maxScore = 0
	for question in result:
		# get question key from reference
		var array = question.name.rsplit("/", true, 0)
		var questionKey = array[array.size() - 1]
		if questionKey in question_keys:
			# get section key from reference
			var array2 = question.fields.section.referenceValue.rsplit("/", true, 0)
			if (array2[array2.size() - 1] == current_section) && (int(question.fields.level.integerValue) == current_level):
				var points = int(question.fields.point.integerValue)
				maxScore += points 
				# get question values
				var qns = {
					"answer": int(question.fields.answer.integerValue),
					"explanation": question.fields.explanation.stringValue,
					"level": int(question.fields.level.integerValue),
					"question": question.fields.question.stringValue,
					"point": int(question.fields.point.integerValue),
					"world": question.fields.world.referenceValue,
					"section": question.fields.section.referenceValue,
					"option": [],
					"questionKey": questionKey
				}
				for option in question.fields.option.arrayValue.values:
					qns["option"].append(option.stringValue)
				questions[questionKey] = qns
	close_dialog()
	start_quiz()
	pass

func fetch_from_db(path):
	Firebase.get_document_or_collection(path, http)


var current_sprite
var current_email
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	# check which http request resulthttp
	
	if json.result.has("name"):
		if "Worlds" in json.result.name: # get Worlds/id collection
			get_world_section_questions_db(json.result)
		if "Users" in json.result.name:
#			var user = json.result;
			if json.result.fields.has('QuizHistory'):
				existing_hist = json.result.fields['QuizHistory'].arrayValue
#				user["QuizHistory"] = json.result.fields['QuizHistory'].arrayValue
				if existing_hist.size() < 1:
					existing_hist = []
				else:
					existing_hist = json.result.fields['QuizHistory'].arrayValue.values
					var timeLog = existing_hist[existing_hist.size()-1].mapValue.fields.attemptedDateTime.stringValue
					if compareTime(timeLog):
						get_tree().change_scene("res://Scenes//Worlds//LevelSelection.tscn")
			else:
				existing_hist = []
			if json.result.fields.has('CompletedWorlds'):
				existing_complete = json.result.fields['CompletedWorlds'].arrayValue
				if existing_complete.size() < 1:
					existing_complete = []
			else:
				existing_complete = []
			if json.result.fields.has('ChallengeHistory'):
				challenge_hist = json.result.fields['ChallengeHistory'].arrayValue
				if challenge_hist.size() < 1:
					challenge_hist = []
				else:
					challenge_hist = json.result.fields['ChallengeHistory'].arrayValue.values
			else:
				challenge_hist = []
			current_email = json.result.fields['Email']
			current_sprite = json.result.fields['UserSprite']
			current_class = json.result.fields['Class']
			current_domain = json.result.fields['Domain']
			current_name = json.result.fields['Name']
			current_uid = json.result.fields['UID']
			fetch_from_db("Worlds/%s" % current_world) # get questions
	elif json.result.has("documents"):
		if "Questions" in json.result.documents[0].name: # get Questions collection
			get_questions_db(json.result.documents)
	else:
		print("JSON")
		print(json.result)
		print("JSON")

func compareTime(timeLog):
	var valid = false
	var dd = str(timeLog.substr(0,2))
	var mm = str(timeLog.substr(3,2))
	var yyyy = str(timeLog.substr(6,4))
	var hr = str(timeLog.substr(13,2))
	var mins = str(timeLog.substr(16,2))
	var secs = str(timeLog.substr(19,2))
	
	if dd == str(day) && mm == str(month):
		if hr == str(hour) && mins == str(minute):
			if secs == str(seconds):
				valid = true
	return valid

func create_selection(qnKey, selected, score):
	var selection := {
		"mapValue": {
			"fields":{
				"questionKey": {"stringValue": qnKey},
				"scoreObtained": {"integerValue": score},
				"selectedAnswer": {"integerValue": selected}
			}
		}
	}
	selection_arr.append(selection)

func create_history(totalScore, world, section, level, qnKey):	
	var mastery = 0
	var avg = float(totalScore) / float(maxScore) * 100
	if avg >= 80:
		mastery = 3
	elif avg >= 50:
		mastery = 2
	else:
		mastery = 1

	var sectionPath = "projects/worldsoftware-9e78c/databases/(default)/documents/Section/" + str(section)
	var history := {
		"mapValue": {
			"fields":{
				"MasteryLvl": {"integerValue": mastery},
				"attemptedDateTime": {"stringValue": str(day) + "/" + str(month) + "/" + str(year) + " , " +  str(hour) + ":" + str(minute) + ":" + str(seconds)},
				"level": {"integerValue": level},
				"maxScore": {"integerValue": maxScore},
				"section": {"referenceValue": sectionPath},
				"totalScore": {"integerValue": totalScore},
				"world": {"integerValue": world},
				"playerKey": {"stringValue": str(current_user)},
				"selectedChoices": {
					"arrayValue": {
						"values": selection_arr
					}
				}
			}
		}
	}
	existing_hist.append(history)
	save_history()

func save_history():
	get_final()
	if totalScore > 0 and current_level == finalLevel and current_section == finalSection:
		var worldPath = "projects/worldsoftware-9e78c/databases/(default)/documents/Worlds/" + str(current_world)
		var complete := {"referenceValue": worldPath} 
		existing_complete.append(complete)
	var path = "Users/"	+ str(current_user)
	if existing_complete.size() == 0:
		existing_complete = {}
		
	var quizhistory := {
		"Class": current_class,
		"ChallengeHistory": {
			"arrayValue": {
				"values": challenge_hist,
			}
		},
		"CompletedTutorial": {"booleanValue": "True"},
		"CompletedWorlds": {
			"arrayValue": existing_complete
		},
		"Domain": current_domain,
		"Name": current_name,
		"UID": current_uid,
		"Email": current_email,
		"UserSprite": current_sprite,
		"QuizHistory": {
			"arrayValue": {
				"values": existing_hist,
			},
		}
	}
	print("done")
	Firebase.update_document(path, quizhistory, http)

func get_final():
	if current_world == 1:
		finalSection = "5eZBbr744PdaQ7CcTXNj"
		finalLevel = 3
	if current_world == 2:
		finalSection = "bVf3VNnFOrdIh4LHTbIM"
		finalLevel = 3
	if current_world == 3:
		finalSection = "toDElsAJAyOT8hoCi9e5"
		finalLevel = 3
	if current_world == 4:
		finalSection = "EgOubttl8bKycJXKVV0l"
		finalLevel = 3

# button pressed events
func _on_OptionButton1_pressed():
	option1.set_normal_texture(options_clicked)
	check_answer(current_question_key, 1)

func _on_OptionButton2_pressed():
	option2.set_normal_texture(options_clicked)
	check_answer(current_question_key, 2)

func _on_OptionButton3_pressed():
	option3.set_normal_texture(options_clicked)
	check_answer(current_question_key, 3)

func _on_OptionButton4_pressed():
	option4.set_normal_texture(options_clicked)
	check_answer(current_question_key, 4)
	
func _on_DialogButton_pressed():
	sprite_node.play("run")
	emit_signal("ok")
	close_dialog()

func _on_Back_pressed():
	get_tree().change_scene("res://Scenes//Worlds//LevelSelection.tscn")
