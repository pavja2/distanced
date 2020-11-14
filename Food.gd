extends StaticBody2D


# Declare member variables here.
var foodType = ""

export var foodToGive : int = 1

func on_interact(player):
	player.give_food(foodToGive)
	queue_free()


# Called when the node enters the scene tree for the first time.
func _ready():
	var food_types = $AnimatedSprite.frames.get_animation_names()
	$AnimatedSprite.animation = food_types[randi() % food_types.size()]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
