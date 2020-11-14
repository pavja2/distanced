extends Area2D


# Declare member variables here.
var food_types = ["apples","bananas","broccoli", "cake", "cheese", "chocolate", 
"croissants", "eggs", "fish", "garlic", "grapes", "ice cream", "kiwis", "milk",
"oranges", "potatoes", "pumpkin", "shrimp", "strawberries", "tea", "tomatoes",
"turkey"]

var foodType = food_types[randi() % food_types.size()]

func on_interact(player):
	player.give_food(foodType)
	queue_free()


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.animation = foodType


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
