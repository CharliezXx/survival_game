extends Node2D

class_name Destructible_obj
var main_scene : PackedScene = preload("res://Scene/world_gen.tscn")
@export var obj_node: Node2D
@export var clickable_area: Area2D
@export var Interactable_zone:Area2D
@export var anim :AnimationPlayer
@export var health: int = 10
@export var have_drop:bool
@export var item_drop_scene:PackedScene
var is_pointing:bool
var player_in_area:bool
var max_health
@export var health_bar:TextureProgressBar 
var damage_timer: Timer = Timer.new()
var is_mouse_held:bool = false
func _ready() -> void:
	
	max_health = health
	update_health_bar()
	if health_bar:
		health_bar.visible = false
		
	# Connect the input event for the clickable area
	if clickable_area:
		clickable_area.connect("input_event",_on_clickable_area_input_event)
		clickable_area.connect("mouse_entered",_mouse_entered)
		clickable_area.connect("mouse_exited",check_pointing)
	
	if Interactable_zone:
		Interactable_zone.connect("area_entered", player_entered_area)
		Interactable_zone.connect("area_exited", player_exited_area)
	
	'''if damage_timer:
		damage_timer.wait_time = .2 # Damage interval in seconds
		damage_timer.connect("timeout", _on_damage_timer_timeout)
		add_child(damage_timer)'''

		
func _process(delta: float) -> void:

	if health_bar:
		if  player_in_area and is_pointing:
			health_bar.visible = true
		else:
			health_bar.visible = false
func player_entered_area(area):
	if area.name =="Player_area":
		#print("entered")
		player_in_area = true
func player_exited_area(area):
	if area.name =="Player_area":
		#print("exited")
		player_in_area = false
		
		restore_health()
func _mouse_entered():
	is_pointing = true
	if is_mouse_held:
		damage_timer.start()
	else:
		damage_timer.stop()
func check_pointing():
	is_pointing	= false	
func _on_clickable_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		is_pointing = true
		if event.pressed and Input.is_action_pressed("left_click") and player_in_area:
			do_dmg() 
			'''is_mouse_held = true
			damage_timer.start()'''
		else:
			pass
			'''is_mouse_held = false
			damage_timer.stop()'''
			
func restore_health():
	if !player_in_area:
		health = max_health
		update_health_bar()
	if is_pointing and player_in_area:
		update_health_bar()
		
func do_dmg() -> void:
	if health > 0:  # Check if health is greater than zero
		health -= 1  # Reduce health by 1
		if anim:
			anim.play("obj_hit")
		update_health_bar()
		print(obj_node.name, " |Health = ",health)
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
			get_parent().add_child(dropped_item)  # Add the dropped item to the scene
	queue_free()
	
func update_health_bar():
	if health_bar:
		health_bar.value= float(health) / max_health * 100 

'''func _on_damage_timer_timeout():
	if is_mouse_held and player_in_area and is_pointing:
		do_dmg()
		if anim:
			anim.play("obj_hit")
		update_health_bar()'''
	
