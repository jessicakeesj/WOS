extends Control
onready var npc_dialogue = get_node("DialoguePanel/NpcDialogue")
onready var npc_name = get_node("DialoguePanel/NpcName")
onready var npc_sprite = get_node("DialoguePanel/NpcSprite")
onready var json = preload("res://Utils//LoadJson.gd").new()

var dialogue_path = "res://Dialogues//"
var sprite_path = "res://Sprites//"
var sprite_type =".png"
var data
var count =1
var file

func _ready():
	return

func set_file(file_name):
	file = file_name

func display_dialogue():
	data = json.load_file(dialogue_path+file)
	display_npc()

func display_npc():
	var name = data[String(count)].name
	var dialogue = data[String(count)].dialogue
	var sprite_head = sprite_path + Global.get_selected_character() + "/" + Global.get_selected_character() +"_Head/"
	
	match(Global.get_selected_character()):
		"Box":
			get_node("DialoguePanel/NpcSprite").set_scale(Vector2(1,1))
		"Jack":
			get_node("DialoguePanel/NpcSprite").set_scale(Vector2(0.3,0.3))
	
	var file_path = Global.get_selected_character().to_lower() +"_head (1).png" 
	var total_path = sprite_head + file_path
	var sprite = load(total_path)
#	print(total_path)
#	print(sprite)
	npc_dialogue.set_visible_characters(0)
	npc_dialogue.set_bbcode(dialogue)
	npc_name.set_bbcode(Global.get_selected_character())
	npc_sprite.set_texture(sprite)
	count+=1

func _on_TextTimer_timeout():
	npc_dialogue.set_visible_characters(npc_dialogue.get_visible_characters()+1)

func next_dialogue(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if(count<=data.size()):
				if(count == data.size()):
					get_node("DialoguePanel/Next").hide()
				display_npc()


func _on_DialoguePanel_gui_input(event):
	next_dialogue(event)


func _on_NpcDialogue_gui_input(event):
	next_dialogue(event)

func _on_NpcName_gui_input(event):
	next_dialogue(event)

func _on_Next_gui_input(event):
	next_dialogue(event)
