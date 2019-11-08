extends Node2D

var stars = [load("res://Assets//Worlds//0 stars.png"),
             load("res://Assets//Worlds//1 stars.png"),
             load("res://Assets//Worlds//2 stars.png"),
             load("res://Assets//Worlds//3 stars.png")]
var path = "Levels/Level"

signal left_clicked
signal right_clicked

func _ready():
	return

func enable_level(index):
	var col_path 
	col_path = path + String(index) + "/CollisionShape2D"
	print(col_path)
	get_node(col_path).set_disabled(false)
func enable_level_icon(index):
	var icon_path = "Levels//Level" + String(index) + "//Level" + String(index)
	var icon_img = load("res://Assets//Worlds//round.png")
	get_node(icon_path).set_texture(icon_img)

	
func display_stars(index, total_score, max_score):
	var path = "Levels//Level%s//Level%s//Stars" % [index, index] 
	var star_node = get_node(path)
	star_node.set_texture(stars[0])
	var percent = float(total_score)/float(max_score) * 100
	
	if percent == 0:
		star_node.set_texture(stars[0])
	elif percent >0 && percent<=50:
		star_node.set_texture(stars[1])
	elif percent >50 && percent<=80:
		star_node.set_texture(stars[2])
	else:
		star_node.set_texture(stars[3])

	star_node.show()
func display_levels(index):
	var icon_path = "Levels//Level%s//Level%s" % [index, index]
	var icon_img = load("res://Assets//Worlds//roundlocked.png")
	get_node(icon_path).set_texture(icon_img)
	get_node(icon_path).show()
func disable_all_levels():
	var count=1
	while count<7:
		var col_path 
		col_path = path + String(count) + "/CollisionShape2D"
		get_node(col_path).set_disabled(true)
		var icon_path = "Levels//Level%s//Level%s" % [count, count]
		var star_path = icon_path + "//Stars"
		var star_node = get_node(star_path)
		star_node.texture = null
		var icon_img = load("res://Assets//Worlds//round.png")
		#get_node(icon_path).set_texture(icon_img)
		get_node(icon_path).hide()
		count+=1

func disable_level(index):
	var col_path 
	col_path = path + String(index) + "/CollisionShape2D"
	get_node(col_path).set_disabled(true)

func enable_left_btn():
	get_node("LeftArea/CollisionShape2D").disabled = false
	get_node("LeftArea").show()
func disable_left_btn():
	get_node("LeftArea/CollisionShape2D").disabled = true
	get_node("LeftArea").hide()
func enable_right_btn():
	get_node("RightArea/CollisionShape2D").disabled = false
	get_node("RightArea").show()
func disable_right_btn():
	get_node("RightArea/CollisionShape2D").disabled = true
	get_node("RightArea").hide()

func _on_HomeArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			get_tree().change_scene("res://Scenes//Worlds//WorldsScreen.tscn")


func _on_LeaderBoardArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			get_tree().change_scene("res://Scenes//Statistics//WorldRanking.tscn")


func _on_Level1_input_event(viewport, event, shape_idx):
		if event is InputEventMouseButton:
			if event.is_pressed():
				Global.set_current_level(1)
				get_tree().change_scene("res://Scenes//Quiz//QuestionScene.tscn")

func _on_Level2_input_event(viewport, event, shape_idx):
		if event is InputEventMouseButton:
			if event.is_pressed():
				Global.set_current_level(2)
				get_tree().change_scene("res://Scenes//Quiz//QuestionScene.tscn")


func _on_Level3_input_event(viewport, event, shape_idx):
		if event is InputEventMouseButton:
			if event.is_pressed():
				Global.set_current_level(3)
				get_tree().change_scene("res://Scenes//Quiz//QuestionScene.tscn")


func _on_Level4_input_event(viewport, event, shape_idx):
		if event is InputEventMouseButton:
			if event.is_pressed():
				Global.set_current_level(4)
				get_tree().change_scene("res://Scenes//Quiz//QuestionScene.tscn")


func _on_Level5_input_event(viewport, event, shape_idx):
		if event is InputEventMouseButton:
			if event.is_pressed():
				Global.set_current_level(5)
				get_tree().change_scene("res://Scenes//Quiz//QuestionScene.tscn")


func _on_Level6_input_event(viewport, event, shape_idx):
		if event is InputEventMouseButton:
			if event.is_pressed():
				Global.set_current_level(6)
				get_tree().change_scene("res://Scenes//Quiz//QuestionScene.tscn")


func _on_LeftArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
			if event.is_pressed():
				emit_signal("left_clicked")


func _on_RightArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
			if event.is_pressed():
				emit_signal("right_clicked")
