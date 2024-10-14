extends CharacterBody2D


const SPEED = 300.0
@onready var player_anim = $AnimationPlayer

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x := Input.get_axis("walk_left", "walk_right")
	var direction_y := Input.get_axis("walk_up", "walk_down")
	if direction_x:
		velocity.x = direction_x * SPEED
		if velocity.x>0:
			player_anim.play("walk_left")
		else :
			player_anim.play("walk_right")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction_y:
		velocity.y = direction_y * SPEED
		player_anim.play("walk_left")
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	if velocity.x ==0 && velocity.y==0:
		player_anim.play("RESET")
		pass

	move_and_slide()
