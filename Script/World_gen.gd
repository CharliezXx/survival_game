@tool
extends Node2D



@export var world_size:float 
@onready var world_Height:float = world_size
@onready var world_Width:float = world_size

@export var tile : Array[TileMapLayer]
@export var noise : FastNoiseLite 


var noise_arr =[]

##LAYERS
var arr_water =[]
var arr_sand =[]
var arr_grass =[]

@export_group("Layer")
@export var water_layer:int
@export var sand_layer:int
@export var grass_layer:int


func _ready() -> void:	

	gen_world()
	gen_tile()
	pass

func  gen_tile():
	tile[grass_layer].set_cells_terrain_connect(arr_grass,2,0)
	tile[sand_layer].set_cells_terrain_connect(arr_sand,1,0)
	
func  gen_world():
	noise.seed =  randi()
	
	for x in world_Height:
		
		for y in world_Width:
			
			#making falloff
			var half_h:float = ((2*(x/world_Width))-1)
			var half_w:float = ((2*(y/world_Height))-1)
			print(half_h,",",half_w)
			var distance = 1 - (1-pow(half_w,2)) * (1-pow(half_h,2))
			#var falloff =[((2*(x/world_Width))-1),((2*(y/world_Height))-1)]
			
			# Set ALT + falloff
			var altitude = noise.get_noise_2d(x,y)-distance
			
			# add noise to arr for check max and min
			noise_arr.append(noise.get_noise_2d(x,y))
			
			# Set Sea background
			tile[0].set_cell(Vector2i(x,y),1,Vector2i(9,10))
			
			# Check which terrain to place according to althitude
			# alt in Simplex noise ->(~0.65 to -0.65)
			if altitude > -0.3:
				arr_sand.append(Vector2i(x,y))
				pass
			if altitude > 0.1:
				arr_grass.append(Vector2i(x,y))
	
		#set_cells_terrain_connect(arr,terrain_set,terrain)
	print(noise_arr.max(),noise_arr.min())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
