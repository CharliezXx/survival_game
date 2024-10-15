extends Node2D
class_name Destructible_obj
@export var obj_to_destroy:Node2D
@export var clickable_area:Area2D

var health : int = 10

# Called when the node enters the scene tree for the first time.
func damage(dmg:int):
	health = health - 2
	if health <= 0:
		queue_free()
	pass
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		
		pass
