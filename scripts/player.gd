extends CharacterBody2D

var 	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const	speed = 120.0
const	jump_force = -400.0

var		can_double_jump: bool = true
var		can_dash: bool = true
var 	can_use_special: bool = true

@onready	var animation = $AnimationPlayer
@onready	var sprite = $Sprite2D
@onready	var	cooldown2s = $cooldown_2s
@onready	var	cooldown10s = $cooldown_10s

###################################################################################################

func	_ready():
	animation.play("idle")

###################################################################################################

func	_physics_process(delta):
	player_input_and_animation(delta)

###################################################################################################

func	walk_and_idle(input):
	# player's horizontal movement
	if input:
		if animation.current_animation != "attack 1" and animation.current_animation != "special":
			animation.play("walk")
		velocity.x = speed * input
		sprite.flip_h = (input == -1)
	# player idle
	else:
		if animation.current_animation != "attack 1" and animation.current_animation != "special":
			animation.play("idle")
		velocity.x = move_toward(velocity.x, 0, speed)

###################################################################################################

func	jump():
	# player's jump
	if (Input.is_action_just_pressed("jump") and is_on_floor()):
		if (animation.current_animation != "attack 1" and animation.current_animation != "special"):
			animation.play("jump")
		velocity.y = jump_force

###################################################################################################

func	double_jump(delta):
	# player's double jump
	if not is_on_floor():
		velocity.y += gravity * delta
		if Input.is_action_just_pressed("jump") and can_double_jump == true:
			velocity.y = jump_force
			can_double_jump = false
	# double jump reset
	if is_on_floor():
		can_double_jump = true

###################################################################################################

func	fall():
	# player's fall
	if velocity.y > 0:
		if animation.current_animation != "attack 1" and animation.current_animation != "special":
			animation.play("fall")

###################################################################################################

func	dash(input):
	# player's dash
	if Input.is_action_just_pressed("dash") and can_dash == true:
		velocity.x = move_toward(velocity.x, 5000 * input, 15000)
		can_dash = false
		cooldown2s.start()
	
###################################################################################################

func	ghost_move(input):
	# player's ghost_move
	if Input.is_action_just_pressed("dash") and can_dash == true:
		if input:
			sprite.flip_h = (input == -1)
			var	tween = get_tree().create_tween()
			tween.tween_property(self, "position:x", position.x + velocity.x * 1, 0.15)
			await tween.finished
			can_dash = false
			cooldown2s.start()

###################################################################################################

func	attack():
	# player's basic attack
	if Input.is_action_just_pressed("attack"):
		animation.play("attack 1")

###################################################################################################

func	special():
	# player's special attack
	if Input.is_action_just_pressed("special") and can_use_special == true:
		animation.play("special")
		can_use_special = false
		cooldown10s.start()

###################################################################################################

func	player_input_and_animation(delta):
	var input =  Input.get_axis("left", "right")
	walk_and_idle(input)
	jump()
	double_jump(delta)
	fall()
	dash(input)
	attack()
	special()
	move_and_slide()

###################################################################################################

func _on_cooldown_2s_timeout():
	# dash reset
	can_dash = true

func _on_cooldown_10s_timeout():
	# special reset
	can_use_special = true
