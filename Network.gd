extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31500
const MAX_PLAYERS = 5

var players = { }

signal server_created # server is launched and controls a socket
signal join_success # The peer joins a server
signal join_fail # The peer fails to join a server
signal player_list_changed # A player has joined or left the game
signal player_removed(pinfo) # A player is removed from the game list


func _on_player_connected(id):
	print("Player with id ", id, " connected to server")

func _on_player_disconnected(id):
	print("Player ", players[id].name, " disconnected from server")
	# Update the player list if we're the server
	if get_tree().is_network_server():
		# Unregister the player from the server's list
		unregister_player(id)
		# Then let remaining peers know about it
		rpc("unregister_player", id)

func _on_connected_to_server():
	emit_signal("join_success")
	# Update player_info with our unique network ID
	gamestate.player_info.net_id = get_tree().get_network_unique_id()
	# Request that the server lets everyone else know about this
	rpc_id(1, "register_player", gamestate.player_info)
	# Finally register the information on our own list too
	register_player(gamestate.player_info)

func _on_connection_failed():
	emit_signal("join_failed")
	# clear the broken network on failure
	get_tree().set_network_peer(null)

func _on_disconnected_from_server():
	print("Disconnected from server")
	# Clear the local internal list
	players.clear()
	# Give them a fresh network ID as a server
	gamestate.player_info.net_id = 1

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("server_disconnected", self, "_on_disconnected_from_server")

func create_server():
	# Init Networking
	var net = NetworkedMultiplayerENet.new()
	
	# Create a Server
	if (net.create_server(DEFAULT_PORT, MAX_PLAYERS) != OK):
		print("Failed to Create Server")
		return
	
	# Connect to a Tree
	get_tree().set_network_peer(net)
	# Emit a signal saying the server has been created successfully
	emit_signal("server_created")
	# Add the server's player to the player list
	register_player(gamestate.player_info)

func join_server(ip, port):
	var net = NetworkedMultiplayerENet.new()
	
	if (net.create_client(ip, port) != OK):
		print("Failed to create Client")
		emit_signal("join_fail")
		return
	
	get_tree().set_network_peer(net)
	
remote func register_player(pinfo):
	if (get_tree().is_network_server()):
		# It's the network server's job to tell everyone else the player list
		for id in players:
			# First we will tell the new player about each of the current players
			rpc_id(pinfo.net_id, "register_player", players[id])
			# The we will tell each of the current players about the new player (other than the server)
			if (id != 1):
				rpc_id(id, "register_player", pinfo)
	# Now we upate our local dictionary for everyone, sever or client
	print("Registering player ", pinfo.name, "(", pinfo.net_id, ") to internal player table")
	players[pinfo.net_id] = pinfo
	emit_signal("player_list_changed")
	

remote func unregister_player(id):
	print("Removing player ", players[id].name, " from internal table")
	# Make a note of the player before we remove them so we can hunt down their scenes
	var pinfo = players[id]
	# Remove the player from the list
	players.erase(id)
	# And tell listeners that the list has changed
	emit_signal("player_list_changed")
	# Emit a signal for the server to clean up this player
	emit_signal("player_removed", pinfo)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
