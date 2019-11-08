extends Node

var path
var data
var file
func _ready():
	pass # Replace with function body.

func load_file(file_path):
	var data_file = File.new()
	if data_file.open(file_path, File.READ) != OK:
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return
	data = data_parse.result
	return data

func get_status():
	var data
	data = load_file("res://Scenes//Worlds//tutorialcleared.json")
	
	if data != null:
		return true
	else:
		return false