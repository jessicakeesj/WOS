extends Node

#var state
var data=[]
var challenges=[]
var current_world = 1
var current_section = "5eZBbr744PdaQ7CcTXNj"
var current_level = 1
#var user_key = "MxJuDhyfUiGfuBpSPki2"
var user_key 

var selected_character = "Dog"

#TO BE CHANGED
#var user_id =  "IqKY6ZzP98NdussuunpviiTs58G2"
var user_id

# For Teacher's Homepage
var select_class = ""
var select_student = ""
var select_user_id = ""
var select_user_email = ""
var summ_class = ""
var strongestArr = Array()
var weakestArr = Array()

var world_tut = "tutorial.json"
var level_tut = "tutorialselectlevel.json"

func get_selected_character():
	return selected_character
func set_selected_character(character):
	self.selected_character = character

func get_world_tut():
	return world_tut
func get_level_tut():
	return level_tut

func get_truncated_ref(p):
	var truncated_string = p.substr(p.find_last("/")+1, p.length())
	return truncated_string

func get_current_world():
	return current_world
func set_current_world(current_world):
	self.current_world = current_world
	
func get_current_section():
	return current_section
func set_current_section(current_section):
	self.current_section = current_section

func get_current_level():
	return current_level
func set_current_level(current_level):
	self.current_level = current_level

func get_user_key():
	return user_key
func set_user_key(user_key):
	self.user_key = user_key
	
func get_user_id():
	return user_id
func set_user_id(user_id):
	self.user_id = user_id

func add_frames(sprite_node, sprite_path, animation_name, frame_per_s):
	sprite_node.frames.remove_animation(animation_name)
	sprite_node.frames.add_animation(animation_name)
	var path = "res://Sprites/%s" % sprite_path
	var files = []

#	sprite_node.play(animation_name)
	var png_files = get_files_in_dir_after_import(path)
	for file in png_files:
		sprite_node.frames.add_frame(animation_name, load(path+file))
	sprite_node.frames.set_animation_speed (animation_name, frame_per_s)
	
func run_animation(sprite_node, sprite_path):
	if sprite_node.animation !="":
		sprite_node.frames.remove_animation("run")
	sprite_node.frames.add_animation("run")
	var path = "res://Sprites/%s/%s_Run/" % [sprite_path, sprite_path]
	var png_files = get_files_in_dir_after_import(path)
	for file in png_files:
		sprite_node.frames.add_frame("run", load(path+file))

	sprite_node.play("run")
	sprite_node.frames.set_animation_speed ("run", 11)
	
	set_scale(sprite_path, sprite_node)
func alt_animation(sprite_node, sprite_path):
	if sprite_node.animation != "":
		sprite_node.frames.remove_animation("alt")
	sprite_node.frames.add_animation("alt")
	var path = "res://Sprites/%s/%s_Alt/" % [sprite_path, sprite_path]
	
	var png_files = get_files_in_dir_after_import(path)
	for file in png_files:
		sprite_node.frames.add_frame("alt", load(path + file))

	sprite_node.play("alt")
	sprite_node.frames.set_animation_speed ("alt", 15)
	
	set_scale(sprite_path, sprite_node)

func set_scale(sprite_name, sprite_node):
	match sprite_name:
		"Jack":
			sprite_node.set_scale(Vector2(0.4, 0.4))
		"Box":
			sprite_node.set_scale(Vector2(1.5, 1.5))
		_:
			sprite_node.set_scale(Vector2(0.6, 0.6))

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	return files
    
func get_files_in_dir_after_import(path):
	var temp_array = list_files_in_directory(path)
	var file_array = []
	for file in temp_array:
		if file.ends_with('.import'):  # Handles the final exported version of the game.
			var file_name = file.replace('.import', '') # this will give something like "sprite_1.png"
			file_array.append(file_name)
		elif file.ends_with('.png'):  # Handles the testing in editor version of the game.
			file_array.append(file)
	return file_array
