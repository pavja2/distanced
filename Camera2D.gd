extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var target = get_parent()


var zoom_factor = 1.1
# Called when the node enters the scene tree for the first time.
func _ready():
	print(target)

func _input(event):
	if event is InputEventMouse:
		if event.is_pressed() and not event.is_echo():
			var mouse_position = event.position
			if event.button_index == BUTTON_WHEEL_UP:
				_zoom_at_point(zoom_factor)
			elif event.button_index == BUTTON_WHEEL_DOWN:
				_zoom_at_point(1 / zoom_factor)

func _zoom_at_point(zoom_change):
	var z0 = zoom # current zoom value
	var z1 = z0 * zoom_change # next zoom value
	zoom = z1


