extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var target = get_node("/root/MainScene/Player")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	position = target.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
