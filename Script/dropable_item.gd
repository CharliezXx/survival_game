extends Node2D
class_name Dropable_item

var time = 90
var speed =1
var amplitude =5
var pos = position
var TIME = 0
@export var collectable_area:Area2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	if collectable_area:
		collectable_area.connect("area_entered",_player_entered_area)
	pass # Replace with function body.
func _player_entered_area(area):
	if area.name == "Player_area":
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	TIME += delta
	position.y = pos.y+ sin(TIME*speed)*amplitude 
	
	pass
