extends Node2D

export (PackedScene) var Food

onready var message = get_node("/root/GroceryScene/CanvasLayer/Message")

var start_position = ""
var list_complete = false

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
	start_position = nactor.position

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

remote func spawn_food(food_items):
	Food = load("res://Food.tscn")
	if (get_tree().is_network_server()):
		if len(gamestate.food_list) == 0:
			var limits = get_viewport_rect().size
			var food_item_list = []
			var food_name_list = []
			
			while len(food_item_list) < 5:
				var food_type = food_types[randi() % food_types.size()]
				
				if !(food_type in food_name_list):
					var food_loc = Vector2(rand_range(0, limits.x), rand_range(0, limits.y))
					var spawn_id = len(food_item_list) + 1
					food_item_list.append({
						'food_type': food_type, 
						'x': food_loc.x,
						'y': food_loc.y,
						'spawn_id': spawn_id
						})
					food_name_list.append(food_type)
			gamestate.update_food_list(food_item_list)
		food_items = gamestate.food_list
		rpc("spawn_food", food_items)
		
	if gamestate.spawned_food == 0:
		if len(gamestate.food_list) == 0:
			gamestate.update_food_list(food_items)
		for food_item in gamestate.food_list:
			var food = Food.instance()
			food.set_food_type(food_item['food_type'])
			food.position = $FoodSpawns.get_node(str(food_item['spawn_id'])).position
			#food.position = Vector2(food_item['x'], food_item['y'])
			add_child(food)
			gamestate.spawned_food +=1

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
		gamestate.enemy_list.append(nbot)
		gamestate.spawned_bots += 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$BeforeGameTimer.start()
	# Connect to listen for when the player list changes
	Network.connect("player_list_changed", self, "_on_player_list_changed")

	# If we are the server, we want to listen for player removals too
	if (get_tree().is_network_server()):
		Network.connect("player_removed", self, "_on_player_removed")

	# Spawn the players on the map
	if (get_tree().is_network_server()):
		spawn_players(gamestate.player_info, 1)
		sync_bots()
		spawn_food([])
	else:
		rpc_id(1, "spawn_players", gamestate.player_info, -1)
		rpc_id(1, "sync_bots")
		rpc_id(1, "spawn_food",[])


var time = 60
var time_to_start = 3

func _on_player_disconnected(id):
	get_node(str(id)).queue_free()

func _on_server_disconnected():
	get_tree().change_scene('res://LobbyMenu.tscn')

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
 # Called every frame. 'delta' is the elapsed time since the previous frame.
 #func _process(delta):
 #	pass

func _on_CountdownTimer_timeout():
	time = time - 1
	if time == 0:
		$CountdownTimer.stop()
		$GameLost.play()
		message.show_message("Out of time!")
	message.update_time(time)

func _on_UI_zero_health():
	$CountdownTimer.stop()
	$GameLost.play()
	message.show_message("No health!")

func _on_BeforeGameTimer_timeout():
	message.show_message(str(time_to_start) + "...")
	if time_to_start == 0:
		message.show_message("Start Game!")
		$GameStart.play()
		$BeforeGameTimer.stop()
		$CountdownTimer.start()
	time_to_start = time_to_start - 1

func _on_Area2D_area_entered(area):
	print(list_complete)
	if list_complete:
		$CountdownTimer.stop()
		$GameWon.play()
		message.show_game_win()


func _on_UI_list_complete():
	list_complete = true
	print(list_complete)
	message.show_message("You got all the items!")
