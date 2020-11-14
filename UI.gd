extends Control

var food_image_dict = {"apples":"tile503.png","bananas":"tile613.png",
"broccoli":"tile389.png", "cake":"tile543.png", "cheese":"tile328.png", 
"chocolate":"tile546.png", "croissants":"tile597.png", "eggs":"tile385.png", 
"fish":"tile383.png", "garlic":"tile390.png", "grapes":"tile551.png", 
"ice cream":"tile678.png", "kiwis":"tile585.png", "milk":"tile247.png",
"oranges":"tile555.png", "potatoes":"tile418.png", "pumpkin":"tile387.png", 
"shrimp":"tile382.png", "strawberries":"tile522.png", "tea":"tile400.png", 
"tomatoes":"tile361.png", "turkey":"tile331.png"}

onready var Gauge : TextureProgress = get_node("HBoxContainer/Bars/Bar/Gauge")
onready var Number : Label = get_node("HBoxContainer/Bars/Bar/Count/Background/Number")

func update_shopping_list (foodTypes):
	for i in range(len(foodTypes)):
		if foodTypes[i] != "":
			var Item : TextureRect = get_node("HBoxContainer/Counters/Counter" + str(i+1) + "/Background/Icon")
			var path = "res://Sprites/Food/" + food_image_dict[foodTypes[i]]
			Item.set_texture(load(path))
		else:
			var Counter : MarginContainer = get_node("HBoxContainer/Counters/Counter" + str(i+1))
			if Counter != null:
				Counter.queue_free()

func update_health(health):
	Gauge.value = Gauge.value - health
	Number.text = str(health)
