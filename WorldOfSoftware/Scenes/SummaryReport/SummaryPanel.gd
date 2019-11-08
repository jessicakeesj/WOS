extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Assume teacher is Course Coordinator, can access to everyone's data
onready var http : HTTPRequest = $HTTPRequest
onready var http2 : HTTPRequest = $HTTPRequest2
var Firebase = load("res://firebase/Firebase.gd").new()
var Firebase2 = load("res://firebase/Firebase.gd").new()
onready var globals = get_node("/root/Global")

const StudentSummaryHeaderItem = preload("res://Scenes/SummaryReport/ProdSummaryStudentDescriptionHeaders.tscn")
const StudentSummaryListItem = preload("res://Scenes/SummaryReport/ProdSummaryStudentDescription.tscn")
const ClassSummaryListItem = preload("res://Scenes/SummaryReport/ProdSummaryDescriptionClass.tscn")
const Spacing = preload("res://Scenes/SummaryReport/Spacing.tscn")
const StudentHeader = preload("res://Scenes/SummaryReport/StudentDescriptionP3.tscn")

var completed = ''
var sectionName = ''



func _ready():
	#Remember to delete this and check dependecies
	#Uncomment when testing
	#globals.summ_class = "SSP4"
	get_tree().get_root().get_node("Node/ClassNameLabel").text = str(globals.summ_class)
	var classSumm = ClassSummaryListItem.instance()
	classSumm.get_node("ClassWeakHeader").text = "Weakest Modules(s):"
	classSumm.get_node("ClassStrongHeader").text = "Strongest Module(s):"
	var complete = ""

	for i in range(0,globals.strongestArr.size()):
   	 complete += globals.strongestArr[i]
	
	var complete2 = ""

	for i in range(0,globals.weakestArr.size()):
    complete2 += globals.weakestArr[i]
	
	classSumm.get_node("ClassWeakSection").text = complete
	classSumm.get_node("ClassStrongSection").text = complete2
	classSumm.rect_min_size=Vector2(814,333)
	$SummaryBoard/ScrollContainer/SummaryList.add_child(classSumm)
	
	var space = Spacing.instance()
	space.rect_min_size=Vector2(814,82)
	$SummaryBoard/ScrollContainer/SummaryList.add_child(space)
	
	var studentHead = StudentHeader.instance()
	studentHead.get_node("WorldName").text = "Student Summary"
	studentHead.rect_min_size=Vector2(814,108)
	$SummaryBoard/ScrollContainer/SummaryList.add_child(studentHead)
	
	var SummHeader = StudentSummaryHeaderItem.instance()
	SummHeader.get_node("Name").text = "Name"
	SummHeader.get_node("Strongest").text = "Strongest"
	SummHeader.get_node("Weakest").text = "Weakest"
	SummHeader.rect_min_size=Vector2(814,85)
	$SummaryBoard/ScrollContainer/SummaryList.add_child(SummHeader)
	
	fetch_from_db("Users")

func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/SummaryReport/Summary.tscn")

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	
	for history in json.result["documents"]:
		var flaggNothing = 0
		# get leadership Document from reference
		var array = history.name.rsplit("/", true, 0)
		var leaderDoc = array[array.size() - 1]
		var array2= history.fields.Domain.stringValue.to_lower()
		#\
		if(history.fields.Class.stringValue == str(globals.summ_class)):
			if(history.fields.Domain.stringValue.to_lower() == "student"):
				var list = {
					"Domain": (history.fields.Domain.stringValue),
					"Name": (history.fields.Name.stringValue),
					"Class": (history.fields.Class.stringValue),
					"UID": (history.fields.UID.stringValue),
					"QuizHistory": [],
					}

				if(history.fields.has('QuizHistory') == true): # heck if quizhistory exist
					if(history.fields.Class.stringValue == globals.summ_class): # check if user belong to the class
						if(history.fields.QuizHistory.arrayValue.size() != 0):
							for QHistory in history.fields.QuizHistory.arrayValue.values: # loop quiz history
								#if("1" in QHistory.mapValue.fields.world.integerValue):
								var array3 = QHistory.mapValue.fields.section.referenceValue.rsplit("/", true, 0)
								#get sectionID
								var section= array3[array3.size() - 1] # get secton id
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
									if ((qh.level == quizHistory["level"]) && (quizHistory["section"] == qh.section)):
										if (quizHistory["attemptedDateTime"] > qh.attemptedDateTime):
											exist = true;
											list["QuizHistory"][i] = quizHistory
									i += 1
								if !exist:
									list["QuizHistory"].append(quizHistory)
						else:
							addStudentSummNothing(history.fields.Name.stringValue)
		
							
				#print(list), it is finally working
				filter(list)
				#addClassSumm()
	print("Done")

func addStudentSummNothing(n):
	var studentSummN = StudentSummaryListItem.instance()
	studentSummN.get_node("StudentName").text = str(n)
	studentSummN.get_node("BestSectionName").text = "-NO DATA-"
	studentSummN.get_node("WeakSectionName").text = "-NO DATA-"
	studentSummN.rect_min_size=Vector2(846,120)
	$SummaryBoard/ScrollContainer/SummaryList.add_child(studentSummN)
			
		

func filter(LList):
	print(LList['Name'])
	print(LList['QuizHistory'])
	print(LList['QuizHistory'].size())


	var weakestSection = ""
	var strongestSection = ""
	var weakestPercentage=0.0
	var strongestPercentage=0.0
	var totalScore = 0.0
	var maxScore  = 0.0
	
	if(LList['QuizHistory'].size() == 0):
		print("size is 0")
	else:
	#section name var outside
		for rows in LList["QuizHistory"]:
			totalScore+=rows['totalScore']
			maxScore+=rows['maxScore']
			var percentage = (totalScore / maxScore) *100
	
			if(strongestPercentage==0.0) :
				strongestPercentage=percentage
				strongestSection = rows['section']
	
			elif(percentage > strongestPercentage ):
				weakestPercentage = strongestPercentage
				weakestSection = strongestSection
				strongestPercentage=percentage
				strongestSection = rows['section']
	
			else:
				if(weakestPercentage==0.0):
					weakestPercentage =percentage
					weakestSection = rows['section']
				elif(weakestPercentage>percentage):
					weakestPercentage=percentage
					weakestSection = rows['section']
	
		# Get the strongest and weakesr levels and section to be displayed
		#print("Strongest section: " + str(strongestSection))
		#print("Strongest Percentage: " + str(strongestPercentage))
		#print("Weakest section: " + str(weakestSection))
		#print("Weakest Percentage: " + str(weakestPercentage))
		addStudentSumm(LList["Name"],strongestSection, weakestSection)
	

		
		# get it once find out
func addStudentSumm(names, strong, weak):
	var studentSummID = StudentSummaryListItem.instance()
	studentSummID.get_node("StudentName").text = str(names)
	
	if(strong == ""):
		studentSummID.get_node("BestSectionName").text = str("-")
	else:
		fetch_from_db2("Section/" + str(strong))
		yield(get_tree().create_timer(3.0), "timeout")
		studentSummID.get_node("BestSectionName").text = sectionName
	
	
	if(weak == ""):
		studentSummID.get_node("WeakSectionName").text = str("-")
	else:
		fetch_from_db2("Section/" + str(weak))
		yield(get_tree().create_timer(3.0), "timeout")
		studentSummID.get_node("WeakSectionName").text = sectionName
		
	studentSummID.rect_min_size=Vector2(846,120)
	$SummaryBoard/ScrollContainer/SummaryList.add_child(studentSummID)

	var exist = 0
	for i in range(0,globals.strongestArr.size()):
		if(globals.strongestArr[i] == studentSummID.get_node("BestSectionName").text):
			exist+=1
	if(exist == 0):
		globals.strongestArr.append(str(studentSummID.get_node("BestSectionName").text))
		get_tree().reload_current_scene()
		
	var exist2 = 0
	for i in range(0,globals.weakestArr.size()):
		if (globals.weakestArr[i] == studentSummID.get_node("WeakSectionName").text):
			exist2+=1
		for a in range(0,globals.strongestArr.size()):
			if(globals.strongestArr[a] == studentSummID.get_node("WeakSectionName").text):
					exist2+=1
	if(exist2 == 0):
		globals.weakestArr.append(str(studentSummID.get_node("WeakSectionName").text))
		get_tree().reload_current_scene()
	
	
	
	

func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	sectionName = json.result.fields.SectionName.stringValue

func _on_BButton_pressed():
	get_tree().change_scene("res://Scenes/SummaryReport/Summary.tscn")
	
func fetch_from_db(path):
	Firebase.get_document_or_collection(path, http)
	
func fetch_from_db2(path):
	Firebase2.get_document_or_collection(path, http2)
	
	
