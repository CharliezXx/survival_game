@tool
extends Node2D

##Generate Button
@export var generate:bool:
	set(value):
		clear()
		gen_world()
		gen_tile()

##Generation Setting Inspector
@export_group("Generation Setting")
@export_range(10,1000,10) var world_size:float =50
@export var use_falloff  : bool=true
@export var use_temperature  : bool=true
@export_range(0,3) var Falloff_multiplier : float = 1.7
@export var noise_for_alt : FastNoiseLite = FastNoiseLite.new()
@export var noise_for_temperature : FastNoiseLite = FastNoiseLite.new()
@export var tile : Array[TileMapLayer]
var noise_arr =[]
var arr_water =[]
var arr_sand =[]
var arr_grass =[]
#############################################
##LAYERS and Altitude Inspector
@export_group("Layer and Altitude")
@export_subgroup("water")
@export var water_layer:int
@export_range(-1,1) var water_alt_max:float = 1
@export_range(-1,1) var water_alt_min:float = -1

@export_subgroup("sand")
@export var sand_layer:int
@export_range(-1,1) var sand_alt_max:float = 1
@export_range(-1,1) var sand_alt_min:float = -0.3

@export_subgroup("grass")
@export var grass_layer:int
@export_range(-1,1) var grass_alt_max:float =  1
@export_range(-1,1) var grass_alt_min:float =  0.3
############################################
@export_group("Random Object Generation")
@export var obj:Array[Dictionary]
'''var tree_obj ={
	"normal_tree": preload("res://Scene/Object/tree_1.tscn"),
 	"short_tree": preload("res://Scene/Object/short_tree1.tscn")
}'''
var rock_obj ={
	
}

func _ready() -> void:	
	clear()
	gen_world()
	gen_tile()

	pass

#Clear tile from PREVIOUS generation
func clear():	
	noise_arr.clear()
	for x in 1000:
		for y in 1000:
			tile[0].erase_cell(Vector2i(x,y))
			tile[1].erase_cell(Vector2i(x,y))
			tile[2].erase_cell(Vector2i(x,y))
			
			tile[water_layer].set_cell(Vector2i(x,y),-1,Vector2i(-1,-1))
			tile[sand_layer].set_cell(Vector2i(x,y),-1,Vector2i(-1,-1))
			tile[grass_layer].set_cell(Vector2i(x,y),-1,Vector2i(-1,-1))
	tile[grass_layer].set_cells_terrain_connect(arr_grass,2,-1)
	tile[sand_layer].set_cells_terrain_connect(arr_sand,1,-1)
	tile[water_layer].set_cells_terrain_connect(arr_water,0,-1)
	arr_water.clear()
	arr_sand.clear()
	arr_grass.clear()

#set_cells_terrain_connect(arr,terrain_set,terrain)
func gen_tile():	
	tile[grass_layer].set_cells_terrain_connect(arr_grass,2,0)
	tile[sand_layer].set_cells_terrain_connect(arr_sand,1,0)
	tile[water_layer].set_cells_terrain_connect(arr_water,0,0)

func  gen_world():
	if noise_for_alt != null:
		noise_for_alt.seed = randi()
		noise_for_temperature.seed =randi(
		
		)
	#Loop Through Size of the map
		for x in world_size:
			for y in world_size:

				#making falloff
				var half_h:float = ((2*(x/world_size))-1)
				var half_w:float = ((2*(y/world_size))-1)
				#print(half_h,",",half_w)
				var distance = 1 - (1-pow(half_w,2)) * (1-pow(half_h,2))
				#var falloff =[((2*(x/world_Width))-1),((2*(y/world_Height))-1)]

				# Set ALT + falloff
				var altitude
				var temperature
				
				if use_falloff:
					altitude = noise_for_alt.get_noise_2d(x,y)-(distance*Falloff_multiplier)
				else:
					altitude = noise_for_alt.get_noise_2d(x,y)

				if use_temperature:
					temperature = noise_for_alt.get_noise_2d(x,y)
				else:
					pass
				# add noise to arr for check max and min
				noise_arr.append(noise_for_alt.get_noise_2d(x,y))

				# Set Sea background
				tile[water_layer].set_cell(Vector2i(x,y),1,Vector2i(9,10))


				# Check which terrain to place according to althitude
				# alt in Simplex noise ->(~0.65 to -0.65)
				if sand_alt_max > altitude and altitude > sand_alt_min:
					arr_sand.append(Vector2i(x,y))
					
						
							
				if grass_alt_max > altitude and altitude > grass_alt_min:
					
					
					
					arr_grass.append(Vector2i(x,y))
					if  temperature > 0.3:
						var change = randf_range(0,1)
						if not Engine.is_editor_hint():
							if change > 0.8:
								gen_obj(grass_layer,obj[0],"normal_tree",x,y)
							elif change > 0.5:
								gen_obj(grass_layer,obj[0],"short_tree",x,y)
								
								
								
								
				if water_alt_max > altitude and altitude > water_alt_min:
					arr_water.append(Vector2i(x,y))


	else:
		print("Noise for Alt can't be null!")


# This Function use for generate node scene 
func gen_obj(layer:int,obj:Dictionary,key:String,x_from_loop:int,y_from_loop:int):
	var object_to_place :Node2D = obj[key].instantiate()
	var tile_pos = tile[layer].map_to_local(Vector2i(x_from_loop,y_from_loop))
	object_to_place.position = tile_pos
	add_child(object_to_place)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
