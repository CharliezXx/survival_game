extends Node2D
class_name Destructable_node

@export var health:int = 10
@export var sprite:Sprite2D
@export var clickable_area:Area2D
@export var obj_to_destroy:World_gen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if clickable_area.mouse_entered:
		print(get_global_mouse_position())
		
		print(name)
		#remove_child(obj_to_destroy.stored_obj)
		pass
	
	pass
