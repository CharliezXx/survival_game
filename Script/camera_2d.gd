extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	zoom = Vector2(2,2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if zoom >= Vector2(1.8,1.8):
		if Input.is_action_just_released("scroll_down"):
			zoom -= Vector2(pow(.5,2),pow(.5,2))
	if zoom <= Vector2(3,3):
		if Input.is_action_just_released("scroll_up"):
			zoom += Vector2(pow(.5,2),pow(.5,2))
	pass
