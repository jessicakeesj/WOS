extends Panel

onready var http : HTTPRequest = $HTTPRequest
var Firebase = load("res://firebase/Firebase.gd").new()

onready var teachersName = get_node("/root/Global")

const PlayersListItem=preload("res://Scenes/SummaryReport/listPlayers.tscn")
const ListPlayersHeaders =preload("res://Scenes/SummaryReport/listPlayersHeaders.tscn")

var playerListIndex=1
var students = []

func addHeader():
	var header = ListPlayersHeaders.instance()
	header.get_node("IndexHeader").text = "Index"
	header.get_node("NameHeader").text = "Name"
	header.get_node("EmailHeader").text = "Email"
	header.get_node("Label").text = "T.Completion"
	header.get_node("AnoHeader").text = "W.Completion"
	header.rect_min_size=Vector2(1479,75)
	$Board/ScrollContainer/list.add_child(header)


# Called when the node enters the scene tree for the first time.
func _ready():
	fetch_from_db("Users") 
	addHeader();
	

func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/Assignments/AssignmentMenu.tscn")
	# Link to Serene's

func _on_ReportButton_pressed():
	get_tree().change_scene("res://Scenes/SummaryReport/ProdSummaryReport.tscn")
	pass # Replace with function body.

func fetch_from_db(path):
	Firebase.get_document_or_collection(path, http)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	# Put teacher's name on Label
	getTeachersName(json)
	
# Getting the student Names
func getStudentNames(infoArr, outputArr):
	if(infoArr.fields.has('Name')):
		# Do we need to check if size is more than 1?
		outputArr.append(infoArr.fields['Name'].values()[0])
	else:
		outputArr.append("-")
	
# Geting the student emails
func getStudentEmails(infoArr, outputArr):
	if(infoArr.fields.has('Email')):
		outputArr.append(infoArr.fields['Email'].values()[0])
	else:
		outputArr.append("-") 

# Printing Teacher's name on Label
func getTeachersName(jsonResult):
	for infoArr in jsonResult.result["documents"]:
		if(infoArr.fields.has('Domain')):
			var teacherDomain = "teacher"
			var check = infoArr.fields['Domain'].values()[0]
			check = check.to_lower()
			#if("zDt83Qf1iNO1liFifv7EFSAD4fg1" == infoArr.fields['UID'].values()[0]):
				#Uncomment after complete testing
			if(teachersName.get_user_id() == infoArr.fields['UID'].values()[0]):
				if(teacherDomain == check):
					get_tree().get_root().get_node("Node/Label").text = str(infoArr.fields['Name'].values()[0])
					# get classes under the teacher
					getStudents(infoArr, jsonResult.result["documents"])
				
func getStudents(teacherArr, json):
	if(teacherArr.fields.has('Class')):
		var tutorialClass = teacherArr.fields["Class"].stringValue
		teachersName.summ_class = teacherArr.fields["Class"].stringValue
		
		for rows in json:
			if(rows.fields.has('Class')):
				if(rows.fields.has('Domain')):
					if(rows.fields['Domain'].values()[0].to_lower() == "student"):
						if(rows.fields["Class"].stringValue == tutorialClass):
							createStudentRows(rows)
							
func createStudentRows(studentArr):
	var student= PlayersListItem.instance()
	student.get_node("Index").text=str(playerListIndex)
	playerListIndex = playerListIndex + 1

	if(studentArr.fields.has('Name')):
		student.get_node("StudentName").text= str(studentArr.fields['Name'].values()[0])
	else:
		student.get_node("StudentName").text = str("-")

	if(studentArr.fields.has('Email')):
		student.get_node("StudentEmail").text = str(studentArr.fields['Email'].values()[0])
	else:
		student.get_node("StudentEmail").text = str("-")
		
	student.get_node("UID").text= str(studentArr.fields['UID'].values()[0])


	if(studentArr.fields.has('CompletedTutorial')):
		if(studentArr.fields['CompletedTutorial'].values()[0] == true):
			student.get_node("MasteryLvl").text = str("Completed")
		else:
			student.get_node("MasteryLvl").text = str("No")
	
	if(studentArr.fields.has('CompletedWorlds')):
		#print(studentArr.fields['Name'].values()[0])
		#print(studentArr.fields['CompletedWorlds'].size())
		if(studentArr.fields['CompletedWorlds'].size() > 0):
			student.get_node("Example").text = str(studentArr.fields['CompletedWorlds'].size())
		else:
			student.get_node("Example").text = str("0")
	
	student.rect_min_size=Vector2(1479,75)
	$Board/ScrollContainer/list.add_child(student)
		
		# Need to get this checked out
		#var classesNo = teacherArr.fields['Class'].arrayValue.values()[0].size()	#returned 2
		# Need to check if array or string
		#var classesNo = teacherArr.fields['Class'].values()[0]
		
		#If there is more than one class
		

