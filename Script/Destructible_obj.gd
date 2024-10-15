extends Node2D

class_name Destructible_obj

@export var obj_to_destroy: Node2D
@export var clickable_area: Area2D

@export var health: int = 10

func _ready() -> void:
	# Connect the input event for the clickable area
	clickable_area.connect("input_event",_on_clickable_area_input_event)

func _on_clickable_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and Input.is_action_pressed("left_click"):  # Check for left mouse button
			do_dmg()

func do_dmg() -> void:
	if health > 0:  # Check if health is greater than zero
		health -= 1  # Reduce health by 1
		print(health)
	if health <= 0:  # Check if health is zero or less
		destroy()  # Call destroy to remove the object

func destroy():
	if obj_to_destroy:
		queue_free()# Remove the specified child object
