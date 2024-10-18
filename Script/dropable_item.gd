extends Node2D
class_name Dropable_item

var time = 90
var speed =1
var amplitude =5
var pos = position
var TIME = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	TIME += delta
	position.y = pos.y+ sin(TIME*speed)*amplitude 
	
	pass
