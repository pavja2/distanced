extends Control

var _player_name= ""
var default_ip = "127.0.0.1"
var default_port = 31500

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _on_TextField_text_changed(new_text):
	_player_name = new_text

func _on_CreateButton_pressed():
	if _player_name == "":
		return
	Network.create_server()

func _on_JoinButton_pressed():
	if _player_name == "":
		return
	Network.join_server(default_ip, default_port)

func _on_ready_to_play():
	# once there is a server, display the map
	get_tree().change_scene("res://GroceryScene.tscn")

func _on_join_fail():
	print("Failed to join server")

# Called when the node enters the scene tree for the first time.
func _ready():
	# The menu will listen for a server that says it is launched
	Network.connect("server_created", self, "_on_ready_to_play")
	
	# This lets a peer connect to a server's map once it joins
	Network.connect("join_success", self, "_on_ready_to_play")
	
	# Prints to console when a peer cannot connect to the server
	Network.connect("join_fail", self, "_on_join_fail")


func _load_game():
	get_tree().change_scene("res://GroceryScene.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
