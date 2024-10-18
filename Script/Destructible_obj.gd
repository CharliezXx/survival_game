extends Node2D

class_name Destructible_obj
var main_scene : PackedScene = preload("res://Scene/world_generate.tscn")
@export var obj_node: Node2D
@export var clickable_area: Area2D
@export var Interactable_zone:Area2D
@export var anim :AnimationPlayer
@export var health: int = 10
@export var have_drop:bool
@export var item_drop_scene:PackedScene
var player_in_area:bool
var max_health
func _ready() -> void:
	max_health = health
	# Connect the input event for the clickable area
	clickable_area.connect("input_event",_on_clickable_area_input_event)
	clickable_area.connect("mouse_exited",restore_health)
	if Interactable_zone:
		Interactable_zone.connect("area_entered", player_entered_area)
		Interactable_zone.connect("area_exited", player_exited_area)
		
func player_entered_area(area):
	if area.name =="Player_area":
		print("entered")
		player_in_area = true
func player_exited_area(area):
	if area.name =="Player_area":
		print("exited")
		player_in_area = false
	
func _on_clickable_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and Input.is_action_pressed("left_click") and player_in_area:
			do_dmg()
			if anim:
				anim.play("obj_hit")
func restore_health():
	health = max_health
		
func do_dmg() -> void:
	if health > 0:  # Check if health is greater than zero
		health -= 1  # Reduce health by 1
		print(health)
	if health <= 0:  
		destroy()  

func destroy():
	if obj_node:
		if !have_drop:
			print("This item don't have drop , Assign drop item")
		else:
			 # Instance the item drop scene and set its position
			var dropped_item = item_drop_scene.instantiate()  # make node2d from packed scene
			dropped_item.position = global_position
			dropped_item.position += Vector2(1,1)*10

			get_parent().add_child(dropped_item)  # Add the dropped item to the scene
	queue_free()
