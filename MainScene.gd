extends Node2D

export (PackedScene) var Food

onready var message = get_node("/root/GroceryScene/CanvasLayer/Message")

# Declare member variables here.

var food_types = ["apples","bananas","broccoli", "cake", "cheese", "chocolate",
"croissants", "eggs", "fish", "garlic", "grapes", "ice cream", "kiwis", "milk",
"oranges", "potatoes", "pumpkin", "shrimp", "strawberries", "tea", "tomatoes",
"turkey"]

puppet var foods_on_screen = []

# Spawns a new player, using the provided player_info and the given spawn index
remote func spawn_players(pinfo, spawn_index):
	# If the spawn index is -1 we define it by the size of the player list
	if spawn_index == -1:
		spawn_index = Network.players.size()

	if (get_tree().is_network_server() && pinfo.net_id != 1):
		#If this is the server host and the requested spawn point is not the server's
		#Iterate through the connected players
		var s_index = 1
		for id in Network.players:
			#Spawn existing players within the new player's scene
			if (id != pinfo.net_id):
				rpc_id(pinfo.net_id, "spawn_players", Network.players[id], s_index)
			# Add the new player to the existing player scenes (except for the server's)
			# The server already knows about the new player and that object can get itself
			if (id != 1):
				rpc_id(id, "spawn_players", pinfo, spawn_index)
			s_index += 1

	# Load a new scene instalce
	var pclass = load(pinfo.actor_path)
	var nactor = pclass.instance()

	#Set the starting position for the new actor
	nactor.position = $SpawnPoints.get_node(str(spawn_index)).position

	#If this actor does not belong to the server, give it to a peer as a puppet
	if (pinfo.net_id != 1):
		nactor.set_network_master(pinfo.net_id)
	nactor.set_name(str(pinfo.net_id))

	#Finally, put the new actor into the world
	add_child(nactor)

remote func despawn_player(pinfo):
	if (get_tree().is_network_server()):
		for id in Network.players:
			# Skip disconnecting the server from the replciation process
			if (id == pinfo.net_id || id == 1):
				continue

			# Otherwise, tell everyone else about the removals
			rpc_id(id, "despawn_player", pinfo)

	var player_node = get_node(str(pinfo.net_id))
	if not player_node:
		print("Cannot remove invalid node from player tree")
		return

	# Mark the player node for deletion
	player_node.queue_free()

func _on_player_removed(pinfo):
	despawn_player(pinfo)

func _on_player_list_changed():
	pass

remote func sync_bots():
	var bot_count = len(gamestate.bot_info)
	if (get_tree().is_network_server()):
		# Relay this to the connected players
		rpc("sync_bots")
	while gamestate.spawned_bots < bot_count:
		var bot_data = gamestate.bot_info[gamestate.spawned_bots+1]
		var bot_class = load(bot_data["actor_path"])
		var nbot = bot_class.instance()
		nbot.set_name(bot_data.name)
		add_child(nbot)
		gamestate.spawned_bots += 1

	#while gamestate.spawned_bots < 1:
	#	var nbot = bot_class.instance()
	#	nbot.set_name(gamestate.bot_info[gamestate.spawned_bots+1].name)
	#	add_child(nbot)
	#	gamestate.spawned_bots += 1

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to listen for when the player list changes
	Network.connect("player_list_changed", self, "_on_player_list_changed")

	# If we are the server, we want to listen for player removals too
	if (get_tree().is_network_server()):
		Network.connect("player_removed", self, "_on_player_removed")

	# Spawn the players on the map
	if (get_tree().is_network_server()):
		spawn_players(gamestate.player_info, 1)
		sync_bots()
	else:
		rpc_id(1, "spawn_players", gamestate.player_info, -1)
		rpc_id(1, "sync_bots")

#	Food = load("res://Food.tscn")
#	randomize()
#	var rand = RandomNumberGenerator.new()
#	var screen_size = get_viewport().get_visible_rect().size
#	while len(foods_on_screen) < 10:
#		var food = Food.instance()
#		if !foods_on_screen.has(food.foodType):
#			foods_on_screen.append(food.foodType)
#			rand.randomize()
#			var x = rand.randf_range(0,screen_size.x)
#			rand.randomize()
#			var y = rand.randf_range(0,screen_size.y)
#			food.position.y = y
#			food.position.x = x
#			add_child(food)
#	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
#	get_tree().connect('server_disconnected', self, '_on_server_disconnected')

#	var new_player = preload('res://Player.tscn').instance()
#	new_player.name = str(get_tree().get_network_unique_id())
#	print("player name", new_player.name)
#	new_player.set_network_master(get_tree().get_network_unique_id())
#
#
#	get_tree().current_scene.find_node("Players").add_child(new_player)
#
#	print(get_tree().current_scene.find_node("Players").get_children())
#	var info = Network.self_data
#	new_player.init(info.name, info.position, false)
var time = 60
#var foods_on_screen = []

# Called when the node enters the scene tree for the first time.
func casey_ready():
	$CountdownTimer.start()
	Food = load("res://Food.tscn")
	randomize()
	var rand = RandomNumberGenerator.new()
	var screen_size = get_viewport().get_visible_rect().size
	while len(foods_on_screen) < 10:
		var food = Food.instance()
		if !foods_on_screen.has(food.foodType):
			foods_on_screen.append(food.foodType)
			rand.randomize()
			var x = rand.randf_range(0,screen_size.x)
			rand.randomize()
			var y = rand.randf_range(0,screen_size.y)
			food.position.y = y
			food.position.x = x
			add_child(food)
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')

	var new_player = preload('res://Player.tscn').instance()
	new_player.name = str(get_tree().get_network_unique_id())
	print("player name", new_player.name)
	new_player.set_network_master(get_tree().get_network_unique_id())


	get_tree().current_scene.find_node("Players").add_child(new_player)

	print(get_tree().current_scene.find_node("Players").get_children())
	var info = Network.self_data
	new_player.init(info.name, info.position, false)

func _on_player_disconnected(id):
	get_node(str(id)).queue_free()

func _on_server_disconnected():
	get_tree().change_scene('res://LobbyMenu.tscn')

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func game_over():
	$CountdownTimer.stop()
	message.show_message("You win!")

 # Called every frame. 'delta' is the elapsed time since the previous frame.
 #func _process(delta):
 #	pass

func _on_CountdownTimer_timeout():
	time = time - 1
	if time == 0:
		$CountdownTimer.stop()
		message.show_message("You lose!")
	message.update_time(time)

func _on_UI_zero_health():
	$CountdownTimer.stop()
	message.show_message("You lose!")
