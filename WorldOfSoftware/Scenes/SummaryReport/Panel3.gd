extends Panel

onready var http : HTTPRequest = $HTTPRequest
onready var http2 : HTTPRequest = $HTTPRequest2
var Firebase = load("res://firebase/Firebase.gd").new()
var Firebase2 = load("res://firebase/Firebase.gd").new()

const StudentListItem=preload("res://Scenes/SummaryReport/StudentDescription.tscn")
const WorldListItem=preload("res://Scenes/SummaryReport/StudentDescriptionP2.tscn")
const NoDataItem = preload("res://Scenes/SummaryReport/NoDataOutput.tscn")
const WorldHeaderListItem=preload("res://Scenes/SummaryReport/StudentDescriptionP3.tscn")
const SpacingItem=preload("res://Scenes/SummaryReport/Spacing.tscn")
onready var globals = get_node("/root/Global")

var completed = ''
var sectionName = ''
var specificStudent = ''
var flagNothing = 0

func _ready():
	# Student Name is working

	
	get_tree().get_root().get_node("StudentNode/Label").text = globals.select_student
	fetch_from_db("Users")

func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/SummaryReport/Summary.tscn")

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	for rows in json.result["documents"]:
		#if "UID" in rows:
		if(rows.fields.has('UID')):
			if(rows.fields["UID"].values()[0] == str(globals.select_user_id)):
				if(rows.fields["QuizHistory"].arrayValue.size() != 0):
					addStudentHeader(rows, json.result["documents"])
				else:
					flagNothing+=1
					addStudentHeader(rows, json.result["documents"])

func fetch_from_db(path):
	Firebase.get_document_or_collection(path, http)
	
func fetch_from_db2(path):
	Firebase2.get_document_or_collection(path, http2)
	
func displayNoData():
	var NoData = NoDataItem.instance()
	NoData.get_node("NoDataLabel").text = "NO DATA"
	NoData.rect_min_size=Vector2(891,351)
	$Board3/ScrollContainer/list3.add_child(NoData)

func addStudentHeader(studentArr, fullArr):
	
	var studentID = StudentListItem.instance()
	# Do the checkings too
	studentID.get_node("Email").text = "Email:"
	if(studentArr.fields.has("Email")):
		studentID.get_node("StudentEmail").text = studentArr.fields["Email"].values()[0]
	else:
		studentID.get_node("StudentEmail").text = str("-")
	
	studentID.get_node("CompletedTutorial").text = "Tutorial:"
	
	if(studentArr.fields.has('CompletedTutorial')):
		if(studentArr.fields["CompletedTutorial"].values()[0] == true):
			studentID.get_node("TutorialAnswer").text = "Completed"
		else:
			studentID.get_node("TutorialAnswer").text = "Incomplete"
	else:
		studentID.get_node("TutorialAnswer").text = "Incomplete"
	
	studentID.get_node("Completed").text = "Completed Worlds: "
	
	if(studentArr.fields.has('CompletedWorlds')):
		# Need to add checking here
		if(studentArr.fields['CompletedWorlds'].arrayValue.size() == 0 ):
			studentID.get_node("CompletedAnswer").text = str(0)
		else:
			completed = str(studentArr.fields['CompletedWorlds'].arrayValue.values()[0].size())
			studentID.get_node("CompletedAnswer").text = str(studentArr.fields['CompletedWorlds'].arrayValue.values()[0].size())
			
	studentID.rect_min_size=Vector2(953,314)
	$Board3/ScrollContainer/list3.add_child(studentID)
	
	if(flagNothing == 1):
		addSpacing()
		displayNoData()
	
	for history in fullArr:
		# get leadership Document from reference
		var array = history.name.rsplit("/", true, 0)
		var leaderDoc = array[array.size() - 1]
		var array2= history.fields.Domain.stringValue
		if(array2=="STUDENT"  && "QuizHistory"  in history.fields):
			var list = {
				"Domain": (history.fields.Domain.stringValue),
				"Name": (history.fields.Name.stringValue),
				"UID": (history.fields.UID.stringValue),
				"QuizHistory": [],
				}
				
			if(history.fields.QuizHistory.arrayValue.values().size() > 0):
				for QHistory in history.fields.QuizHistory.arrayValue.values:
					var array3 = QHistory.mapValue.fields.section.referenceValue.rsplit("/", true, 0)
					#get sectionID
					var section= array3[array3.size() - 1]
					var quizHistory = {
						"MasteryLvl": int(QHistory.mapValue.fields.MasteryLvl.integerValue),
						"attemptedDateTime": QHistory.mapValue.fields.attemptedDateTime.stringValue,
						"level": int(QHistory.mapValue.fields.level.integerValue),
						"section": section,
						"totalScore": int(QHistory.mapValue.fields.totalScore.integerValue),
						"maxScore": int(QHistory.mapValue.fields.maxScore.integerValue),
						"world": int(QHistory.mapValue.fields.world.integerValue)
						}
	
					# loop existing list of quizhistory
					var exist = false
					var i = 0
	
					for qh in list["QuizHistory"]:
						if ((quizHistory["level"] == qh.level) && (quizHistory["section"] == qh.section)):
							list["QuizHistory"][i] = quizHistory # if record newer replace old record								exist = true
							exist = true
						i+=1
					if !exist:
						list["QuizHistory"].append(quizHistory)
						
				filter(list)
		

# filter through everything
func filter(LList):
	var worlds = Array()
	
	for i in range(LList["QuizHistory"].size()):
		var exist = false
		var flag = 0
		if(worlds.size() == 0):
			worlds.append(LList["QuizHistory"][i]['level'] )
			flag = 1
		else:
			for r in range(worlds.size()):
				if(LList["QuizHistory"][i]['level'] == worlds[r]):
					exist = true
					
		if (!exist && flag == 0):
			worlds.append(LList["QuizHistory"][i]['level'] )
			
	# Gets the specific student only
	# Not based on completed worlds
	if(LList["Name"] == globals.select_student):
		for w in worlds:
			#prints world
			addSpacing()
			addWorldHeader(w)
			for h in LList["QuizHistory"]:
				if(h["world"] == w):
					#print("level: " + str(LList["QuizHistory"][i]['level']))
					fetch_from_db2("Section/" + str(str(h['section'])))
					yield(get_tree().create_timer(3.0), "timeout")
					 #can do after ere
					print("section: "+ str(sectionName))
					print("world: " + str(h['world']))
					addWorldInfo(sectionName, h['level'], h['attemptedDateTime'], h['MasteryLvl'], h['totalScore'] , h['maxScore'])
					#prints level and section for that wor
			
		
func addSpacing():
	var space = SpacingItem.instance()
	space.rect_min_size=Vector2(814,82)
	$Board3/ScrollContainer/list3.add_child(space)

func addWorldHeader(index):
	var worldID = WorldHeaderListItem.instance()
	worldID.get_node("WorldName").text = "World " + str(index)
	worldID.rect_min_size=Vector2(745,100)
	$Board3/ScrollContainer/list3.add_child(worldID)
	
func addWorldInfo(section, lvl, attempt, mastery, total, maxs):
	var worldInfo = WorldListItem.instance()
	worldInfo.get_node("Section").text = "Section: " + str(section)
	worldInfo.get_node("Level").text = "Level: " + str(lvl)
	worldInfo.get_node("LatestAttempt").text = "Latest Attempt:"
	worldInfo.get_node("AttemptAnswer").text = str(attempt)
	worldInfo.get_node("MasteryLvl").text = "Mastery: "
	worldInfo.get_node("MasteryAnswer").text = str(mastery)
	worldInfo.get_node("TotalScore").text = "Total Score:"
	worldInfo.get_node("ScoreAnswer").text = str(total) + " / " + str(maxs)
	worldInfo.rect_min_size=Vector2(868,379)
	$Board3/ScrollContainer/list3.add_child(worldInfo)
	

func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result.fields.SectionName.stringValue)
	sectionName = json.result.fields.SectionName.stringValue
	