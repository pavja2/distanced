extends Control

var _player_name= ""


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _on_TextField_text_changed(new_text):
	_player_name = new_text

func _on_CreateButton_pressed():
	if _player_name == "":
		return
	Network.create_server(_player_name)
	_load_game()

func _on_JoinButton_pressed():
	if _player_name == "":
		return
	Network.connect_to_server(_player_name)
	_load_game()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _load_game():
	get_tree().change_scene("res://GroceryScene.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
