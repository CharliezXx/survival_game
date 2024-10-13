@tool
extends Node2D
@export var gen:bool:
	set(value):
		clear()
		gen_world()
		gen_tile()



@export_range(10,1000,10) var world_size:float =50
@export var use_falloff  : bool=true
@export_range(0,3) var Falloff_multiplier : float = 1.7
@export var noise : FastNoiseLite = FastNoiseLite.new()

var noise_arr =[]


var arr_water =[]
var arr_sand =[]
var arr_grass =[]
@export var tile : Array[TileMapLayer]
##LAYERS and Altitude
@export_group("Layer and Altitude setting")
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


func _ready() -> void:	
	clear()
	gen_world()
	gen_tile()
	
	pass
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
	noise.seed = randi()
	
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
			if use_falloff:
				altitude = noise.get_noise_2d(x,y)-(distance*Falloff_multiplier)
			else:
				altitude = noise.get_noise_2d(x,y)
			# add noise to arr for check max and min
			noise_arr.append(noise.get_noise_2d(x,y))
			
			# Set Sea background
			tile[water_layer].set_cell(Vector2i(x,y),1,Vector2i(9,10))
			
			# Check which terrain to place according to althitude
			# alt in Simplex noise ->(~0.65 to -0.65)
			if sand_alt_max > altitude and altitude > sand_alt_min:
				arr_sand.append(Vector2i(x,y))
			if grass_alt_max > altitude and altitude > grass_alt_min:
				arr_grass.append(Vector2i(x,y))
			if water_alt_max > altitude and altitude > water_alt_min:
				arr_water.append(Vector2i(x,y))
		
	#print(noise_arr.max(),noise_arr.min())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
