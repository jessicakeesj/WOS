extends Panel

const ListItem=preload("res://Scenes/Statistics/itemList.tscn")

onready var http = get_node("../HTTPRequest")
onready var column: VBoxContainer = $board/ScrollContainer/list
onready var title = get_node("../Label")

var Firebase=load("res://firebase/Firebase.gd").new()

var rankNo:int = 1
var totalScore:int = 0
var organiseArray = []
var arrayID = 0
var a = 1
#rows data
var current_world

# Called when the node enters the scene tree for the first time.
func _ready():
	current_world = Global.get_current_world() # get current world
	title.set_text("World %s Ranking" % current_world) # set title
	get_highscores()

func fetch_from_db(path):
	Firebase.get_document_or_collection(path, http)

func get_highscores():
	Firebase.get_document_or_collection("Users", http)
	
func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/Statistics/MasteryLevel.tscn")

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())

	if json.result.has("documents"): # all users
		if "Users" in json.result.documents[0].name:
			get_result_db(json.result.documents)

func get_result_db(result):
	for history in result:
		# get leadership Document from reference
		var array = history.name.rsplit("/", true, 0)
		var leaderDoc = array[array.size() - 1]
		var array2 = history.fields.Domain.stringValue
		if(array2 == "STUDENT"  && "QuizHistory" in history.fields):
			var list = {
				"Domain": (history.fields.Domain.stringValue),
				"Name": (history.fields.Name.stringValue),
				"QuizHistory": []
				}
			if(history.fields.QuizHistory.arrayValue.size() != 0):
				for QHistory in history.fields.QuizHistory.arrayValue.values:
					if(str(current_world) in QHistory.mapValue.fields.world.integerValue):
						var array3 = QHistory.mapValue.fields.section.referenceValue.rsplit("/", true, 0)
						# get sectionID
						var section = array3[array3.size() - 1]
						var quizHistory = {
							"MasteryLvl": int(QHistory.mapValue.fields.MasteryLvl.integerValue),
							"attemptedDateTime": QHistory.mapValue.fields.attemptedDateTime.stringValue,
							"level": int(QHistory.mapValue.fields.level.integerValue),
							"section": section,
							"totalScore": int(QHistory.mapValue.fields.totalScore.integerValue),
							}
						
						# loop existing list of quizhistory
						var exist = false
						var i = 0
						for qh in list["QuizHistory"]:
							if ((quizHistory["level"] == qh.level) && (quizHistory["section"] == qh.section)): # check if existing quizhistory from level and section exist
								if (quizHistory["attemptedDateTime"] > qh.attemptedDateTime): # if exists check which is the latest record
									list["QuizHistory"][i] = quizHistory # if record newer replace old record								exist = true
									exist=true
							i+=1
						if !exist:
							list["QuizHistory"].append(quizHistory)
			if list['QuizHistory'] != []:
				organiseArray.append(list)
	filterScore()
		
func filterScore():
	# calculate users total score
	for i in range(0, organiseArray.size()):
		var total_score = 0.0
		var user = organiseArray[i]
		for data in user.QuizHistory:
			total_score += data.totalScore
		user["Scores"] = total_score
	
	# sort by decending
	if(organiseArray.size() > 1):
		for i in range(0, organiseArray.size()):
			for j in range(0, organiseArray.size()):
				if (organiseArray[i].Scores > organiseArray[j].Scores):
					var temp = organiseArray[j]
					organiseArray[j] = organiseArray[i]
					organiseArray[i] = temp
	
	# display leaderboard
	for a in organiseArray.size():
		displayItem(organiseArray)

func displayItem(finalResult:Array):
	var item=ListItem.instance()
	item.get_node("number").text = str(rankNo)
	item.get_node("Name").text = organiseArray[arrayID].Name
	item.get_node("Points").text = str(organiseArray[arrayID].Scores)
	rankNo += 1
	arrayID += 1
	item.rect_min_size = Vector2(547,129)
	column.add_child(item)

func _on_TextureButton_pressed():
	get_tree().change_scene("res://Scenes//Worlds//LevelSelection.tscn")

