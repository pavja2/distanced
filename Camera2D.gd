extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var target = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	print(target)

func _process(delta):
	position = target.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
