extends CharacterBody2D


@export var SPEED:float = 300.0
@onready var player_anim = $AnimationPlayer

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("walk_left", "walk_right")
	input_vector.y = Input.get_axis("walk_up", "walk_down")
	input_vector.normalized()
	if input_vector:
		velocity = input_vector * SPEED
		if velocity.x>0:
			player_anim.play("walk_left")
		elif velocity.x<0 :
			player_anim.play("walk_right")
	else:
		velocity = input_vector
	
		
	if velocity.x ==0 && velocity.y==0:
		player_anim.play("RESET")
		pass
	
	move_and_slide()
