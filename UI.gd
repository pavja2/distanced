extends Control

onready var foodText : Label = get_node("FoodText")

# updates the gold text Label node
func update_food_text (food):
	
	foodText.text = "Food: " + str(food)
