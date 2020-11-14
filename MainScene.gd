extends Node2D

export (PackedScene) var Food

# Declare member variables here.

var food_types = ["apples","bananas","broccoli", "cake", "cheese", "chocolate", 
"croissants", "eggs", "fish", "garlic", "grapes", "ice cream", "kiwis", "milk",
"oranges", "potatoes", "pumpkin", "shrimp", "strawberries", "tea", "tomatoes",
"turkey"]

var foods_on_screen = []

# Called when the node enters the scene tree for the first time.
func _ready():
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
