extends CharacterBody2D

var 	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const	speed = 20.0

var		player
var		aggroed: bool = false

###################################################################################################

func	_ready():
	pass

###################################################################################################

func	_physics_process(delta):
	enemy_movement(delta)

###################################################################################################

func	fall(delta):
	velocity.y += gravity * delta	

###################################################################################################

func	aggro_player():
	if aggroed == true:
		player = get_node("../player")
		var	direction = (player.position - self.position).normalized()
		velocity.x = direction.x * speed
	else:
		velocity.x = 0

###################################################################################################

func	enemy_movement(delta):
	fall(delta)
	aggro_player()
	move_and_slide()
	
###################################################################################################

func _on_player_detection_body_entered(body):
	if body.name == "player":
		aggroed = true


func _on_player_detection_body_exited(body):
	if body.name == "player":
		aggroed = false
