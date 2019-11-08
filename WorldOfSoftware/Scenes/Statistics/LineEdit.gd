extends LineEdit
var Star3 = preload("res://Images/star_1.png")
var Star2 = preload("res://Images/star_2.png")
var Star1 = preload("res://Images/star_3.png")
var Star0 = preload("res://Images/star_4.png")

onready  var Border=get_node("../brownBorder")
onready  var starImage=get_node("../brownBorder/Table/RatingStar")
onready var point=get_node("../brownBorder/Table/Points")

	
func _ready():
	connect("text_entered",self,"_on_text_entered")

func _on_text_entered(text):
	Border.visible=true
	point.set_text(text)
	ratingResult(text.to_int())


	
#mystery Level
func ratingResult(result:int):
	#delay
	var t=Timer.new()
	t.set_wait_time(2)
	add_child(t)
	t.start()
	#make the script stop with yield
	yield(t,"timeout")

		
	
	if(result==90):
		point.visible=true
		
		var player= AudioStreamPlayer.new()
		self.add_child(player)
		player.stream=load("res://Sounds/media.io_3star.wav")
		player.play()
		starImage.set_texture(Star3)
			
		starImage.visible=true
		
	elif(result==50):
		point.visible=true
		var player= AudioStreamPlayer.new()
		self.add_child(player)
		player.stream=load("res://Sounds/media.io_2star.wav")
		player.play()
		starImage.set_texture(Star2)
		starImage.visible=true
			
	else:
		point.visible=true
		var player= AudioStreamPlayer.new()
		self.add_child(player)
		player.stream=load("res://Sounds/1star.wav")
		player.play()
			
		starImage.set_texture(Star1)
		starImage.visible=true

