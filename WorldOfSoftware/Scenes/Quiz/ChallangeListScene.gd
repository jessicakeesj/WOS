extends Node2D

#export (NodePath) var scroll_container
export (NodePath) var vbox_container
export (NodePath) var background
export (NodePath) var saveButton
export (NodePath) var challengeButton
export (NodePath) var popupDialog
export (NodePath) var popupLabel
export (NodePath) var popupLabelDesc
export (NodePath) var popupButton
export (NodePath) var popupButtonTxt
export (NodePath) var popupFBTxt
export (NodePath) var popupFBBtn
export (NodePath) var popupTwitTxt
export (NodePath) var popupTwitBtn
export (NodePath) var popupShareLabel

#onready var s_container = get_node(scroll_container)
onready var fb_txt = get_node(popupFBTxt)
onready var fb_btn = get_node(popupFBBtn)
onready var twit_txt = get_node(popupTwitTxt)
onready var twit_btn = get_node(popupTwitBtn)
onready var popup_share = get_node(popupShareLabel)

onready var v_container = get_node(vbox_container)
onready var worldBG = get_node(background)
onready var save = get_node(saveButton)
onready var checkBoxNode
onready var http =get_node("HTTPRequest")
onready var column: VBoxContainer=$Panel/ScrollContainer/list
onready var popup = get_node(popupDialog)
onready var popupTxt = get_node(popupLabel)
onready var popupTxtDesc = get_node(popupLabelDesc)
onready var popupBtn = get_node(popupButton)
onready var popupBtnTxt = get_node(popupButtonTxt)

var btn = load("res://Assets//Quiz//medium.png")
var world1_Image = load("res://Assets//Quiz//World//background.png")
var row = load("res://Scenes/Quiz/GridRow.tscn")
var pos_y = 10
var count:int=5
var current_user = "y4vhvl5smZYWk60HmIes"
var assets_path
var listIndex=0
var deleting_entries := false
var Firebase=load("res://firebase/Firebase.gd").new()
var dialog
var dialog_bg
var font_path = "res://Fonts//"
# How many times test loops are ran. Higher is slower, but gives better average.
const ITERATIONS = 1
const ListItem=preload("res://Scenes/Quiz/GridRow.tscn") #edit from here

func _ready():
	Global.start_test("challenge question list (ChallangeListScene.tscn)")
	for i in range(0,ITERATIONS):
		init()
		get_questions()

func init():
	dialog = load("res://Assets//Quiz//World//dialog_button.png")
	dialog_bg = load("res://Assets//Quiz//World//Window.png")
	worldBG.texture = world1_Image
	popup.set_normal_texture(dialog_bg)
	popupBtn.set_normal_texture(dialog)
	popupTxtDesc.add_color_override("font_color", Color(0,0,0))
	
	var candy_bean = load(font_path+"Candy Beans.otf")
	popupTxt.add_font_override("font", candy_bean)
	popupTxtDesc.add_font_override("font", candy_bean)
	popupBtnTxt.add_font_override("font", candy_bean)

# prompt dialog
func popup_dialog(text, description, showButton):
	popupTxt.set_text(text)
	popupTxtDesc.set_text(description)
	popup.show()
	popupTxt.show()
	popupTxtDesc.show()
	fb_txt.show()
	fb_btn.show()
	twit_btn.show()
	twit_txt.show()
	popup_share.show()
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
	fb_txt.hide()
	fb_btn.hide()
	twit_btn.hide()
	twit_txt.hide()
	popup_share.hide()
	get_tree().change_scene("res://Scenes/Quiz/ChallengeMenu.tscn")

#creating new rows
func addItem(questions):
	for qn in questions:
		var rowScene = row.instance()
		v_container.add_child(rowScene)
		checkBoxNode = rowScene.get_node("CheckBox")
		checkBoxNode.text = qn.question
	Global.stop_test(ITERATIONS)

func _on_challengeButton_pressed():
	get_tree().change_scene("res://Scenes/Quiz/ChallengerList.tscn")
	pass

func add_new_rows(Questions: Array) -> void:
	var item=ListItem.instance()
	for Question in Questions:
		addItem(Question)

func get_questions() -> void:
	Firebase.get_document_or_collection("Questions", http)
	
func delete_current_rows() -> void:
	for child in column.get_children():
		if child is ScoreRow:
			child.queue_free()

func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var json = JSON.parse(body.get_string_from_utf8())
	match response_code:
		200:
			if !json.result.has("documents"):
				challenge_msg(json.result.name)
	if "documents" in json.result.keys():
		var questions := get_formated_questions(json.result.documents)
		addItem(questions)

func challenge_msg(result):
	var array = result.rsplit("/",true,0)
	var challenge_key = array[array.size()-1]
	var msg = "Take up the challenge \nby entering this key:\n" + str(challenge_key)
	popup_dialog("Created!", str(msg), true)
	print(str(msg))

var questions := []
func get_formated_questions(documents: Array) -> Array:
	## document.fields.bonus... is the database columns
	for document in documents:
		var split := document.name.split("/") as PoolStringArray
		questions.append({
			"question": document.fields.question.stringValue,
			#"Bonus": int(document.fields.Bonus.integerValue),
			#"Stage_Rank":int(document.fields.Stage_Rank.integerValue),
			"id": split[split.size() - 1]
		})
	return questions

var qn_key = []
func _on_ChallengeButton_pressed():
	var selected = Global.challenges
	for qn in questions:
		for sel in selected:
			if(qn.question == sel):
				qn_key.append(qn.id)
	Global.challenges = qn_key
	save_challenge()
	pass # Replace with function body.
	
var pathArr = []
func create_values():
	pathArr.clear()
	var sel = Global.challenges
	for s in sel:
		var qnPath = "projects/worldsoftware-9e78c/databases/(default)/documents/Question/" + s
		var path := {"referenceValue": qnPath} 
		pathArr.append(path)

func save_challenge():
	create_values()
	var path = "Challenge"
	var userPath = "projects/worldsoftware-9e78c/databases/(default)/documents/Users/" + str(current_user)
	var challenge := {
		"User": {"referenceValue": userPath},
		"Questions": {
			"arrayValue": {
				"values": pathArr
			},
		}
	}
	Firebase.save_document(path, challenge, http)	
	Global.challenges = []
	#code to change scene here

func _on_DialogButton_pressed():
	close_dialog()
	pass # Replace with function body.

func _on_FBButton_pressed():
	OS.shell_open("https://www.facebook.com/groups/413176259616810/")
	pass # Replace with function body.

func _on_TwitButton_pressed():
	OS.shell_open("https://twitter.com/home")
	pass # Replace with function body.

func _on_BacKButton_pressed():
	get_tree().change_scene("res://Scenes/Quiz/ChallengeMenu.tscn")
	pass # Replace with function body.
