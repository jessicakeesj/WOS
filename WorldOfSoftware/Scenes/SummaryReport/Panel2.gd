extends Panel

onready var http : HTTPRequest = $HTTPRequest
var Firebase = load("res://firebase/Firebase.gd").new()

onready var selectedClass = get_node("/root/Global")

const PlayersListItem=preload("res://Scenes/SummaryReport/listPlayers.tscn")
const ListPlayersHeaders =preload("res://Scenes/SummaryReport/listPlayersHeaders.tscn")

var playerListIndex=1

func addHeader():
	var header = ListPlayersHeaders.instance()
	header.get_node("IndexHeader").text = "Index"
	header.get_node("NameHeader").text = "Name"
	header.get_node("EmailHeader").text = "Email"
	header.get_node("AnoHeader").text = "Completion"
	header.rect_min_size=Vector2(1173,75)
	$Board/ScrollContainer/list.add_child(header)

func _ready():
	fetch_from_db("Users")
	get_tree().get_root().get_node("StudentsNode/Label").text = selectedClass.select_class
	addHeader()


func fetch_from_db(path):
	Firebase.get_document_or_collection(path, http)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	getStudents(json)

func getStudents(jsonResult):
	for rows in jsonResult.result["documents"]:
		if(rows.fields.has('Class')):
			if(rows.fields.has('Domain')):
				if(rows.fields['Domain'].values()[0].to_lower() == "student"):
					if(rows.fields['Class'].values()[0] == selectedClass.select_class):
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


	if(studentArr.fields.has('CompletedTutorial')):
		if(studentArr.fields['CompletedTutorial'].values()[0] == true):
			student.get_node("MasteryLvl").text = str("Completed")
		else:
			student.get_node("MasteryLvl").txt = str("No")
	
	if(studentArr.fields.has('CompletedWorlds')):
		if(studentArr.fields['CompletedWorlds'].arrayValue.values()[0].size() > 0):
			student.get_node("Example").text = str(studentArr.fields['CompletedWorlds'].arrayValue.values()[0].size())
		else:
			student.get_node("Example").text = str("-")
	
	student.rect_min_size=Vector2(1221,75)
	$Board/ScrollContainer/list.add_child(student)
	
			
		
	
	#getTeachersName(json)
	#print(json.result["documents"][0])
	#for rows in json.result["documents"]:
	#	var studentInfo = Array()
	#	var studentDomain = "student"
		# Formatted all domain names into lower cases (in case of standardisation)
	#	var check = rows.fields['Domain'].values()[0]
	#	check = check.to_lower()
	#	if( check == studentDomain):
	#		getStudentNames(rows, studentInfo)
	#		getStudentEmails(rows,studentInfo)
			
			# Checking how to ger reference value
			#if(rows.fields['Name'].values()[0] == "Jacky"):
			#	var completed = rows.fields['CompletedWorlds'].arrayValue.values()[0].size()
			#	studentInfo.append(completed)
			#else:
			#	var nothing  = "-"
			#	studentInfo.append(nothing)
				 # Used to relatively collect all the number of worlds
				# To print out reference value
				#print(rows.fields['CompletedWorlds'].arrayValue.values()[0][1])
		# Create another array?
			#print("\n")
			#students.append(studentInfo)
		# Use student arr and put it into another array <- This may help

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/SummaryReport/Summary.tscn")
	



