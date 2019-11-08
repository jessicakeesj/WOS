extends Node

const ListItem=preload("res://Scenes/Student_Mastery/ItemList.tscn")

onready var http =get_node("HTTPRequest")
onready var column: VBoxContainer=$BackgroundImg/Board/ScrollContainer/List
onready var title = get_node("BackgroundImg/Board/World1")

var Firebase=load("res://firebase/Firebase.gd").new()

var id:int = 1
var filterArray=[]
var rankNo=1
var current_world
# Called when the node enters the scene tree for the first time.
func _ready():
	current_world = Global.get_current_world()
	title.set_text("World %s" % current_world) # set title	
	get_result()

func get_result() -> void:
	Firebase.get_document_or_collection("Users", http)
	
func get_result_data(result):
	for history in result:
		# get leadership Document from reference
		var array = history.name.rsplit("/", true, 0)
		var leaderDoc = array[array.size() - 1]
		var array2= history.fields.Domain.stringValue
		if(array2=="STUDENT"  && "QuizHistory" in history.fields):
			var list = {
				"Domain": (history.fields.Domain.stringValue),
				"Name": (history.fields.Name.stringValue),
				"QuizHistory": [],
				
				}
			if(history.fields.QuizHistory.arrayValue.size() != 0):
				for QHistory in history.fields.QuizHistory.arrayValue.values:
					if(str(current_world) in QHistory.mapValue.fields.world.integerValue):
						var array3 = QHistory.mapValue.fields.section.referenceValue.rsplit("/", true, 0)
						#get sectionID
						var section= array3[array3.size() - 1]
						var quizHistory = {
							"MasteryLvl": int(QHistory.mapValue.fields.MasteryLvl.integerValue),
							"attemptedDateTime": QHistory.mapValue.fields.attemptedDateTime.stringValue,
							"level": int(QHistory.mapValue.fields.level.integerValue),
							"section": section,
							"totalScore": int(QHistory.mapValue.fields.totalScore.integerValue),
							"selectedChoices": [QHistory.mapValue.fields.selectedChoices.arrayValue],
							}
						
						# loop existing list of quizhistory
						var exist = false
						var i = 0
			#			print(list["QuizHistory"])
						for qh in list["QuizHistory"]:
			#				print(quizHistory["attemptedDateTime"])
							if ((quizHistory["level"] == qh.level) && (quizHistory["section"] == qh.section)): # check if existing quizhistory from level and section exist
								if (quizHistory["attemptedDateTime"] > qh.attemptedDateTime): # if exists check which is the latest record
									list["QuizHistory"][i] = quizHistory # if record newer replace old record								exist = true
									exist=true
							i+=1
						if !exist:
							list["QuizHistory"].append(quizHistory)
			if(list["QuizHistory"] != []):
				filterArray.append(list)
	filterMastery()

func displayItem(student):
	print(student)
	var item=ListItem.instance()
	item.get_node("Id").text = str(rankNo)
	item.get_node("Name").text = student.Name
	item.get_node("quesNo").text="Attempted: "+str(student.question)+" Ques"
	if(student.percentage<50.0):
		item.get_node("VBoxContainer/3Star").hide()
		item.get_node("VBoxContainer/2Star").hide()
		item.get_node("VBoxContainer/1Star").show()
	elif(student.percentage>50.0 && student.percentage<80.0):
			item.get_node("VBoxContainer/3Star").hide()
			item.get_node("VBoxContainer/2Star").show()
			item.get_node("VBoxContainer/1Star").hide()
	else:
		item.get_node("VBoxContainer/3Star").show()
		item.get_node("VBoxContainer/2Star").hide()
		item.get_node("VBoxContainer/1Star").hide()
	rankNo+=1
	item.rect_min_size=Vector2(567,129)
	$BackgroundImg/Board/ScrollContainer/List.add_child(item)

func filterMastery():
	for i in range(0, filterArray.size()):
		var NoOfQuestions = 0
		var starsObtained = 0.0
		var maxStars = 0.0
		var user = filterArray[i]
		for data in user.QuizHistory:
#			#to get the number of stars obtained
			starsObtained+=data.MasteryLvl
#			#the maximum stars that they can get
			maxStars+=3
			NoOfQuestions+=data.selectedChoices.size()
		# to calculate the percentage
		var Cal=(starsObtained/maxStars)*100
		user["question"] = NoOfQuestions
		user["percentage"] = Cal

	# sort by decending
	if(filterArray.size() > 1):
		for i in range(0, filterArray.size()):
			for j in range(0, filterArray.size()):
				if (filterArray[i].question > filterArray[j].question):
						var temp = filterArray[j]
						filterArray[j] = filterArray[i]
						filterArray[i] = temp
	
	for a in filterArray:
		displayItem(a)
			
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var request_result := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	if "Users" in request_result.documents[0].name:
		get_result_data(request_result.documents)

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes//Statistics//WorldRanking.tscn")