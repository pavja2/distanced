extends KinematicBody2D

onready var ui = get_node("/root/GroceryScene/CanvasLayer/UI")
onready var message = get_node("/root/GroceryScene/CanvasLayer/Message")
onready var main = get_node("/root/GroceryScene")


var moveSpeed : int = 5.0
var damage : int = 20
var damageDist : int = 100

var interactDist : int = 100

var vel = Vector2()
var facingDir = Vector2()

enum MoveDirection { UP, DOWN, LEFT, RIGHT, NONE }

onready var rayCast = $RayCast2D
onready var anim = $AnimatedSprite
var contact_zone

puppet var puppet_position = Vector2()
puppet var puppet_movement = MoveDirection.NONE

var shopping_list = []

# override this function so we can identify player zones
func is_class(type):
	return type == "Player" or .is_class(type)

func _ready ():
	gamestate.connect("food_list_updated", self, '_on_food_list_update')
	var contact_zone_class = load('res://distance_area.tscn')
	contact_zone = contact_zone_class.instance()
	add_child(contact_zone)
	contact_zone.connect("area_entered", self, '_on_area_entered')

	if is_network_master():
		$Camera2D.current = true
	else:
		$Camera2D.current = false

func _on_food_list_update():
	while len(shopping_list) < 3:
		var allowed_foods = gamestate.food_list
		var food_task = allowed_foods[randi() % allowed_foods.size()]
		if !shopping_list.has(food_task['food_type']):
			shopping_list.append(food_task['food_type'])
	if is_network_master():
		ui.update_shopping_list(shopping_list)

func _physics_process(delta):
	var direction = MoveDirection.NONE
	if is_network_master():
		if Input.is_action_pressed('move_left'):
			direction = MoveDirection.LEFT
		elif Input.is_action_pressed('move_right'):
			direction = MoveDirection.RIGHT
		elif Input.is_action_pressed('move_up'):
			direction = MoveDirection.UP
		elif Input.is_action_pressed('move_down'):
			direction = MoveDirection.DOWN
		elif Input.is_action_just_pressed("interact"):
			try_interact()
		rset_unreliable('puppet_position', position)
		rset('puppet_movement', direction)
		_move(direction)
	else:
		_move(puppet_movement)
		position = puppet_position

func _move(direction):
	match direction:
		MoveDirection.NONE:
			vel = Vector2(0, 0)
		MoveDirection.UP:
			vel  = Vector2(0, -moveSpeed)
			facingDir = Vector2(0, -1)
		MoveDirection.DOWN:
			vel = Vector2(0, moveSpeed)
			facingDir = Vector2(0, 1)
		MoveDirection.LEFT:
			vel = Vector2(-moveSpeed, 0)
			facingDir = Vector2(-1, 0)
		MoveDirection.RIGHT:
			vel = Vector2(moveSpeed, 0)
			facingDir = Vector2(1, 0)
	move_and_collide(vel)
	manage_animations()

func _process (delta):
	pass

func try_interact ():
	print("Interaction")
	rayCast.cast_to = facingDir * interactDist
	if rayCast.is_colliding():
		print("Colliding")
		if rayCast.get_collider().has_method("on_interact"):
			print("collided with ", rayCast.get_collider())
			rayCast.get_collider().on_interact(self)

func give_food (foodType):
	if foodType in shopping_list:	
		var foodIndex = shopping_list.find(foodType)
		shopping_list[foodIndex] = ""
		if is_network_master():
			ui.update_shopping_list(shopping_list)
			shopping_list[foodIndex] = "completed"
			

func manage_animations ():
	if vel.x > 0:
		play_animation("MoveRight")
	elif vel.x < 0:
		play_animation("MoveLeft")
	elif vel.y < 0:
		play_animation("MoveUp")
	elif vel.y > 0:
		play_animation("MoveDown")
	elif facingDir.x == 1:
		play_animation("IdleRight")
	elif facingDir.x == -1:
		play_animation("IdleLeft")
	elif facingDir.y == -1:
		play_animation("IdleUp")
	elif facingDir.y == 1:
		play_animation("IdleDown")

func play_animation (anim_name):
	if anim.animation != anim_name:
		anim.play(anim_name)

func take_damage(damage):
	if is_network_master():
		ui.update_health(damage)

func _on_area_entered(area):
	var collide_parent = area.get_parent()
	if collide_parent.is_class("Enemy") or collide_parent.is_class("Player"):
		take_damage(damage)
