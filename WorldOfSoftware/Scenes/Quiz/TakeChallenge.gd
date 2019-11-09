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
export (NodePath) var challengekeytext
export (NodePath) var challengekeybutton
export (NodePath) var challengeKeyDialog
export (NodePath) var challengeKeyTitle
export (NodePath) var challengeKeyBtnLabel
export (NodePath) var backButton

onready var backBtn = get_node(backButton)
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
onready var challengeTxt = get_node(challengekeytext)
onready var challengeBtn = get_node(challengekeybutton)
onready var challengeKey = get_node(challengeKeyDialog)
onready var challengeBtnLabel = get_node(challengeKeyBtnLabel)
onready var challengeTitle = get_node(challengeKeyTitle)

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
var challengekey
var selection_arr = []
var history_arr = []
var question_keys = []

var current_question_key = "hHgqShTzku8hhR7X9XPf"
var current_answer
var error = false
var end = false

signal response
signal ok
signal finish

func _ready():
	current_user = Global.user_key
	initiate()

func get_challengekey(key):
	var path = "Challenge/" + key
	fetch_from_db(path)

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
	options_clicked = load(assets_path+"button-clicked.png")
	dialog = load(assets_path+"dialog_button.png")
	dialog_bg = load(assets_path+"Window.png")
	# set resources
	worldBG.texture = world_bg
	popup.set_normal_texture(dialog_bg)
	popupBtn.set_normal_texture(dialog)
	popupTxtDesc.add_color_override("font_color", Color(0,0,0))
	challengeKey.set_normal_texture(dialog_bg)
	challengeBtn.set_normal_texture(dialog)
	# set font
	var candy_bean = load(font_path+"Candy Beans.otf")
	optionTxt1.add_font_override("font", candy_bean)
	optionTxt2.add_font_override("font", candy_bean)
	optionTxt3.add_font_override("font", candy_bean)
	optionTxt4.add_font_override("font", candy_bean)
	popupTxt.add_font_override("font", candy_bean)
	popupTxtDesc.add_font_override("font", candy_bean)
	popupBtnTxt.add_font_override("font", candy_bean)
	scoreTxt.add_font_override("font", candy_bean)
	

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
		scoreObtained = questions[question_key]["point"]
		popup_dialog("Correct!", questions[question_key]["explanation"], true)
	else: # wrong answer selected
		scoreObtained = 0
		popup_dialog("Wrong!", questions[question_key]["explanation"], true)
	
	update_total_score()
	scoreTxt.set_text(str(totalScore))
	emit_signal("response")

# update total score
func update_total_score():
	var total_score = 0
	totalScore += scoreObtained

func wrongKey(text,description,showButton):
	challengeBtnLabel.hide()
	challengeKey.hide()
	challengeTitle.hide()
	challengeBtn.hide()
	challengeTxt.hide()
	popup_dialog(text, description, showButton)

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
	challengeTxt.hide()
	challengeBtn.hide()
	challengeKey.hide()
	challengeBtnLabel.hide()
	challengeTitle.hide()
	popupTxt.set_text("")
	popupTxtDesc.set_text("")
	popup.hide()
	popupTxt.hide()
	popupTxtDesc.hide()
	popupBtn.hide()
	popupBtnTxt.hide()
	scoreTxt.show()
	if end == true:
		end_quiz()
	if error == true:
		get_tree().change_scene("res://Scenes/Quiz/ChallengeMenu.tscn")

func start_quiz():
	for qns in questions:
		setup_question(questions[qns])
		yield(self,"response")
	end = true

func end_quiz():
	popup_dialog("Your score is: %s" % totalScore, "", true)
	create_values()
	end = false;

func get_questions_db(result):
	maxScore = 0
	for question in result:
		var array = question.name.rsplit("/", true, 0)
		var questionKey = array[array.size() - 1]
		for key in question_keyArr:
			if (str(key) == str(questionKey)):
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

var question_keyArr = []
var challenge_hist
var current_sprite
var current_email
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result.has("name"):
		if json.result.fields.has('Questions'):
				var ref = json.result.fields['Questions'].arrayValue.values
				for r in ref:
					var keys = r.referenceValue.rsplit("/", true, 0)
					question_keyArr.append(keys[keys.size()-1])
				fetch_from_db("Users/" + current_user) # get history
		if "Users" in json.result.name:
			if json.result.fields.has('QuizHistory'):
				existing_hist = json.result.fields['QuizHistory'].arrayValue
				if existing_hist.size() < 1:
					existing_hist = []
				else:
					existing_hist = json.result.fields['QuizHistory'].arrayValue.values
			else:
				existing_hist = []
			if json.result.fields.has('CompletedWorlds'):
				existing_complete = json.result.fields['CompletedWorlds'].arrayValue
				if existing_complete.size() < 1:
					existing_complete = []
				else:
					existing_complete = json.result.fields['CompletedWorlds'].arrayValue.values
			else:
				existing_complete = []
			if json.result.fields.has('ChallengeHistory'):
				challenge_hist = json.result.fields['ChallengeHistory'].arrayValue
				print(challenge_hist)
				if challenge_hist.size() < 1:
					challenge_hist = []
				else:
					challenge_hist = json.result.fields['ChallengeHistory'].arrayValue.values
					var timeLog = challenge_hist[challenge_hist.size()-1].mapValue.fields.attemptedDateTime.stringValue
					if compareTime(timeLog):
						get_tree().change_scene("res://Scenes/Quiz/ChallengeMenu.tscn")
			else:
				challenge_hist = []
			current_email = json.result.fields['Email']
			current_sprite = json.result.fields['UserSprite']
			current_class = json.result.fields['Class']
			current_domain = json.result.fields['Domain']
			current_name = json.result.fields['Name']
			current_uid = json.result.fields['UID']
			fetch_from_db("Questions") # get questions
	elif json.result.has("documents"):
		if "Questions" in json.result.documents[0].name: # get Questions collection
			get_questions_db(json.result.documents)
	else:
		error = true
		wrongKey("ERROR", "Invalid Key",true)

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

var pathArr = []
func create_values():
	var path := {
		"mapValue": {
			"fields":{
				"ChallengeKey": {"stringValue": challengekey},
				"ScoreObtained": {"integerValue": totalScore},
				"MaxScore": {"integerValue": maxScore},
				"attemptedDateTime": {
					"stringValue": str(day) + "/" + str(month) + "/" + str(year) + " , " +  str(hour) + ":" + str(minute) + ":" + str(seconds)
				},
			}
		}
	}
	challenge_hist.append(path)
	save_history()

func save_history():
	var path = "Users/" + str(current_user)	
	var history := {
		"Class": current_class,
		"ChallengeHistory": {
			"arrayValue": {
				"values": challenge_hist,
			}
		},
		"CompletedTutorial": {"booleanValue": "True"},
		"CompletedWorlds": {
			"arrayValue": {
				"values": existing_complete,
			}
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
	Firebase.update_document(path, history, http)

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
	emit_signal("ok")
	close_dialog()

func _on_InputButton_pressed():
	challengekey = challengeTxt.text
	get_challengekey(challengekey)
	backBtn.show()
	pass # Replace with function body.

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Quiz/ChallengeMenu.tscn")
	pass # Replace with function body.
