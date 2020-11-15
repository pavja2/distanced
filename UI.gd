extends Control

signal zero_health
signal list_complete

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
	var completed_values = 0
	for i in range(len(foodTypes)):
		if foodTypes[i] != "" and foodTypes[i] != "completed":
			var Item : TextureRect = get_node("HBoxContainer/Counters/Counter" + str(i+1) + "/Background/Icon")
			var path = "res://Sprites/Food/" + food_image_dict[foodTypes[i]]
			Item.set_texture(load(path))
		elif foodTypes[i] == "":
			var Counter : MarginContainer = get_node("HBoxContainer/Counters/Counter" + str(i+1))
			if Counter != null:
				Counter.queue_free()
		else:
			completed_values += 1
			
	if completed_values >= 2:
		emit_signal("list_complete")


func update_health(health):
	var current_health = Gauge.value - health
	Gauge.value = current_health
	Number.text = str(current_health)
	if current_health == 0:
		emit_signal("zero_health")
