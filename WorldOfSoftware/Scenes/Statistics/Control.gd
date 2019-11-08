extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Star3 = preload("res://Images/star_1.png")
var Star2 = preload("res://Images/star_2.png")
var Star1 = preload("res://Images/star_3.png")
var Star0 = preload("res://Images/star_4.png")

onready  var starImage=get_node("MasteryPanel/brownBorder/Table/RatingStar")

#onready var Star=get_node("MasteryPanel/brownBorder/Table/Points")
# Called when the node enters the scene tree for the first time.
func _ready():

	
	
