extends Control

onready var levelText : Label = get_node("BG/LevelBG/LevelText")
onready var healthBar : TextureProgress = get_node("BG/HealthBar")
onready var xpBar : TextureProgress = get_node("BG/XpBar")
onready var goldText : Label = get_node("BG/GoldText")

# updates the level text Label node
func update_level_text (level):
	
	levelText.text = str(level)

# updates the health bar TextureProgress value
func update_health_bar (curHp, maxHp):
	
	healthBar.value = (100 / maxHp) * curHp

# updates the xp bar TextureProgress value
func update_xp_bar (curXp, xpToNextLevel):
	
	xpBar.value = (100 / xpToNextLevel) * curXp

# updates the gold text Label node
func update_gold_text (gold):
	
	goldText.text = "Gold: " + str(gold)
