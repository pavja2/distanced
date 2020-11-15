extends Control

signal start_game

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func show_game_win():
	show_message("You got all the items!")
	
func show_game_loss():
	show_message("You Lose!")

func show_message(text):
	$ResultMessage.text = text
	$ResultMessage.show()
	$MessageTimer.start()

func update_time(time):
	$CountdownTimer.text = str(time)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_MessageTimer_timeout():
	$ResultMessage.hide()
