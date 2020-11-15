extends KinematicBody2D

var damageDist : int = 80
var move_speed = 100
export (NodePath) var patrol_path
var patrol_points
var patrol_index = 0
var contact_zone

puppet var repl_position = Vector2()

# override this function so we can identify player zones
func is_class(type):
	return type == "Enemy" or .is_class(type)

func _ready():
	var contact_zone_class = load('res://distance_area.tscn')
	contact_zone = contact_zone_class.instance()
	add_child(contact_zone)

	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()

func _physics_process(delta):
	if (is_network_master()):
		if !patrol_path:
			rset("repl_position", position)
			return
		var target = patrol_points[patrol_index]
		if position.distance_to(target) < 1:
			patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
			target = patrol_points[patrol_index]
		var velocity = (target - position).normalized() * move_speed
		move_and_slide(velocity)
		rset("repl_position", position)
	else:
		position = repl_position
