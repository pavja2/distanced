extends Node

signal food_list_updated

# This represents the local player
var player_info = {
	name = "Player",
	net_id = 1,
	actor_path = "res://Player.tscn"
}

var spawned_bots = 0
var spawned_food = 0

var food_list = []
var enemy_list = []

var bot_info = {
	1 : { 
		"name" : "bot_1", "actor_path":"res://bots/bot1.tscn"
	},
	2 : {
		"name" : "bot_2", "actor_path":"res://bots/bot2.tscn"
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	pass # Replace with function body.

func update_food_list(food_data):
	food_list = food_data
	emit_signal("food_list_updated")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
