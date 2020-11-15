extends KinematicBody2D

onready var ui = get_node("/root/GroceryScene/CanvasLayer/UI")
onready var message = get_node("/root/GroceryScene/CanvasLayer/Message")
onready var main = get_node("/root/GroceryScene")
#onready var enemy1 = get_node("/root/GroceryScene/Node/Enemy")
#onready var enemy2 = get_node("/root/GroceryScene/Node2/Enemy")

var moveSpeed : int = 5.0
var damage : int = 20
var damageDist : int = 300

var interactDist : int = 70

var vel = Vector2()
var facingDir = Vector2()

enum MoveDirection { UP, DOWN, LEFT, RIGHT, NONE }

onready var rayCast = $RayCast2D
onready var anim = $AnimatedSprite

puppet var puppet_position = Vector2()
puppet var puppet_movement = MoveDirection.NONE

var shopping_list = []

func _ready ():
	if is_network_master():
		$Camera2D.current = true
	else:
		$Camera2D.current = false

	$EnemyNearTimer.start()

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
	if Input.is_action_just_pressed("interact"):
		try_interact()

func try_interact ():
	rayCast.cast_to = facingDir * interactDist
	if rayCast.is_colliding():
		if rayCast.get_collider().has_method("on_interact"):
			rayCast.get_collider().on_interact(self)

func give_food (foodType):
	if foodType in shopping_list:
		shopping_list[shopping_list.find(foodType)] = ""
	ui.update_shopping_list(shopping_list)

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
	ui.update_health(damage)

func init(nickname, start_position, is_puppet):
	global_position = start_position
	while len(shopping_list) < 3:
		var allowed_foods = main.foods_on_screen
		var food_type = allowed_foods[randi() % allowed_foods.size()]
		if !shopping_list.has(food_type):
			shopping_list.append(food_type)
	ui.update_shopping_list(shopping_list)
	if not is_puppet:
		$Camera2D.current = true
	else:
		$Camera2D.current = false

func _on_EnemyNearTimer_timeout():
	pass
	#if position.distance_to(enemy1.position) <= damageDist or position.distance_to(enemy2.position) <= damageDist:
	#	take_damage(damage)
