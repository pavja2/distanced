extends Area2D


# Declare member variables here.
var food_types = ["apples","bananas","broccoli", "cake", "cheese", "chocolate", 
"croissants", "eggs", "fish", "garlic", "grapes", "ice cream", "kiwis", "milk",
"oranges", "potatoes", "pumpkin", "shrimp", "strawberries", "tea", "tomatoes",
"turkey"]

var foodType = ""
puppet var repl_position = Vector2()
puppet var rotate_left = 0
puppet var repl_rotate_left = 0

remotesync func set_rotate_left(degrees):
	rotate_left = 360

func on_interact(player):
	player.give_food(foodType)
	rpc('set_rotate_left', 360)

func _process(delta):
	if rotate_left > 0:
		rotation_degrees -= 10
		rotate_left -= 10

func set_food_type(food_type):
	self.foodType = food_type
	$Sprite.animation = foodType

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.animation = foodType
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
