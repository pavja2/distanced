extends Control

var _player_name= ""
var default_ip = "127.0.0.1"
var default_port = 31500

onready var JitsiLink = get_node("PlayerMenu/JitsiLink")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _on_TextField_text_changed(new_text):
	_player_name = new_text

func _on_CreateButton_pressed():
	print(JitsiLink)
	gamestate.player_info['name'] = _player_name
	var link = generate_jitsi_link()
	JitsiLink.text = "Join Video Chat:\n" + link
	$ConnectionMenu.hide()
	$PlayerMenu.show()
	Network.create_server()
	refresh_lobby()

func _on_StartButton_pressed():
	Network.begin_game()

func _on_JoinButton_pressed():
	gamestate.player_info['name'] = _player_name
	Network.join_server(default_ip, default_port)
	$ConnectionMenu.hide()
	$PlayerMenu.show()
	refresh_lobby()

func generate_jitsi_link():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var number = rng.randi_range(0, 10000)
	var link = "https://meet.jit.si/DistancedGameGroup" + str(number)
	return link

remotesync func on_game_start():
	get_tree().change_scene("res://GroceryScene.tscn")

func _on_ready_to_play():
	refresh_lobby()
	# once there is a server, display the map
	#get_tree().change_scene("res://GroceryScene.tscn")

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
	
	Network.connect("player_list_changed", self, "refresh_lobby")
	
	_player_name = $ConnectionMenu/HBoxContainer/NameField.text

func refresh_lobby():
	var players = Network.players
	$PlayerMenu/JoinList/MarginContainer/PlayerList.clear()
	$PlayerMenu/JoinList/MarginContainer/PlayerList.add_item(gamestate.player_info['name'] + " (You)")
	for p in players.values():
		#Don't add ourselves twoce
		if p['net_id'] != gamestate.player_info['net_id']:
			$PlayerMenu/JoinList/MarginContainer/PlayerList.add_item(p['name'])
	
	# Only the host gets a start button
	if not get_tree().is_network_server():
		$PlayerMenu/HBoxContainer/Start.hide()
		$PlayerMenu/HBoxContainer/WaitingLabel.show()
	else:
		$PlayerMenu/HBoxContainer/Start.show()
		$PlayerMenu/HBoxContainer/WaitingLabel.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
