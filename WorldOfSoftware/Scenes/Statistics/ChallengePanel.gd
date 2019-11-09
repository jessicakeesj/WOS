extends Panel

const ListItem=preload("res://Scenes/Statistics/itemList.tscn")

onready var http =get_node("../HTTPRequest")
onready var column: VBoxContainer=$board/ScrollContainer/list


var deleting_entries := false
var Firebase=load("res://firebase/Firebase.gd").new()
var highscore_count : int = 5
var rankNo:int =1
var totalScore:int=0
var document_keys = []
var organiseArray=[]
var arrayID=0
#rows data

func _ready():
	get_highscores()
	#let the get_highScores run first
	var t=Timer.new()
	t.set_wait_time(4)
	add_child(t)
	t.start()
	#make the script stop with yield
	yield(t,"timeout")
	for a in organiseArray.size():
		displayItem(organiseArray)
	

func fetch_from_db(path):
	Firebase.get_document_or_collection(path, http)

func get_highscores() -> void:
	Firebase.get_document_or_collection("Users", http)
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result.has("documents"): # all users
		if "Users" in json.result.documents[0].name:
			get_result_db(json.result.documents)

func get_result_db(result):
	var challengeHistory = []
	for history in result:
		# get leadership Document from reference
		var array = history.name.rsplit("/", true, 0)
		var leaderDoc = array[array.size() - 1]
		var array2 = history.fields.Domain.stringValue
		if(array2 == "STUDENT"  && "ChallengeHistory" in history.fields):
			var list = {
				"Name": history.fields.Name.stringValue,
				"ChallengeHistory":[],
				}
			if(history.fields.ChallengeHistory.arrayValue.size()!=0):
				for CHistory in history.fields.ChallengeHistory.arrayValue.values:
						var challengeScore= {
								"cScore": int(CHistory.mapValue.fields.ScoreObtained.integerValue)
							}
						list["ChallengeHistory"].append(challengeScore)
				challengeHistory.append(list)
	filterScore(challengeHistory)


func displayItem(finalResult):
	var item=ListItem.instance()
	item.get_node("number").text=str(rankNo)
	item.get_node("Name").text=finalResult.Name
	item.get_node("Points").text=str(finalResult.Scores)
	rankNo+=1
	item.rect_min_size=Vector2(547,129)
	$Board/ScrollContainer/list.add_child(item)
	
func filterScore(result):
	print(result)
#	# calculate users total score
	for i in range(0, result.size()):
		var total_score = 0.0
		var user = result[i]
		for data in user.ChallengeHistory:
			total_score += data.cScore
		user["Scores"] = total_score

	# sort by decending
	if(result.size() > 1):
		for i in range(0, result.size()):
			for j in range(0, result.size()):
				if (result[i].Scores > result[j].Scores):
					var temp = result[j]
					result[j] = result[i]
					result[i] = temp

	# display leaderboard
	for a in result:
		displayItem(a)
	
func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes//Quiz//ChallengeMenu.tscn")
	pass # Replace with function body.
