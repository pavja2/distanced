extends KinematicBody2D

var moveSpeed : int = 5.0
var damage : int = 1

var interactDist : int = 70

var vel = Vector2()
var facingDir = Vector2()

enum MoveDirection { UP, DOWN, LEFT, RIGHT, NONE }

onready var rayCast = $RayCast2D
onready var anim = $AnimatedSprite

puppet var puppet_position = Vector2()
puppet var puppet_movement = MoveDirection.NONE

func _ready ():
	pass


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
	
	if get_tree().is_network_server():
		Network.update_position(int(name), position)

func _move(direction):
	match direction:
		MoveDirection.NONE:
			return
		MoveDirection.UP:
			move_and_collide(Vector2(0, -moveSpeed))
			facingDir = Vector2(0, -1)
		MoveDirection.DOWN:
			move_and_collide(Vector2(0, moveSpeed))
			facingDir = Vector2(0, 1)
		MoveDirection.LEFT:
			move_and_collide(Vector2(-moveSpeed, 0))
			facingDir = Vector2(-1, 0)
		MoveDirection.RIGHT:
			move_and_collide(Vector2(moveSpeed, 0))
			facingDir = Vector2(1, 0)
	manage_animations()
		
func _process (delta):
	
	if Input.is_action_just_pressed("interact"):
		try_interact()
	
func try_interact ():
	pass

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

func init(nickname, start_position, is_puppet):
	global_position = start_position
	if not is_puppet:
		$Camera2D.current = true
	else:
		$Camera2D.current = false
