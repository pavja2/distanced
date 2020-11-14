extends Control

onready var foodText : Label = get_node("FoodText")
onready var ShoppingList : Label = get_node("ShoppingList")

# updates the gold text Label node
func update_food_text (foodType):
	foodText.text = "Food: " + str(foodType)

func update_shopping_list (foodTypes):
	var foodList = ""
	for foodType in foodTypes:
		foodList += str(foodType) + "\n"
	ShoppingList.text = "Shopping List:\n" + foodList
