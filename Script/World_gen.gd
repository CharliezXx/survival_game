
extends Node2D
class_name World_gen
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
@export_range(-1,1) var water_alt_max:float = 0
@export_range(-1,1) var water_alt_min:float = -1

@export_subgroup("sand")
@export var sand_layer:int
@export_range(-1,1) var sand_alt_max:float = 1
@export_range(-1,1) var sand_alt_min:float = -0.4

@export_subgroup("grass")
@export var grass_layer:int
@export_range(-1,1) var grass_alt_max:float =  2
@export_range(-1,1) var grass_alt_min:float =  -0.3
############################################
@export_group("Random Object Generation")
@export var random_size:bool=true
@export_range(1,2) var max_random_size:float = 1.2
@export var random_facing:bool=true
@onready var obj:Dictionary ={
	"oak_tree":preload("res://Scene/Object/oak_tree.tscn"),
	"oak_sapling":preload("res://Scene/Object/oak_sapling.tscn"),
	"birch_tree":preload("res://Scene/Object/birch_tree.tscn"),
	"spruce_tree":preload("res://Scene/Object/spruce_tree.tscn"),
	"small_spruce":preload("res://Scene/Object/small_spruce.tscn"),
	"grass_normal":preload("res://Scene/Object/grass.tscn"),
	"grass_short":preload("res://Scene/Object/short_grass.tscn")
	
}

#Player

var isplayer_spawn:bool=false
var player = preload("res://Scene/player.tscn").instantiate()
var count:int=0

func _ready() -> void:	
	if tile and obj:
		noise_for_temperature.frequency = 0.0255
		clear()
		while !isplayer_spawn:
			gen_world()
			gen_tile()
		pass
	else:
		print("no tile to place")
#Clear tile from PREVIOUS generation
func clear():
	if tile and obj:
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
	if tile and obj:	
		tile[grass_layer].set_cells_terrain_connect(arr_grass,2,0)
		tile[sand_layer].set_cells_terrain_connect(arr_sand,1,0)
		tile[water_layer].set_cells_terrain_connect(arr_water,0,0)



func  gen_world():
	if tile and obj:
		if noise_for_alt == null:
			print("must assign altitude noise")
		elif noise_for_temperature == null:
			print("must assign temperature noise")
		else:
			noise_for_alt.seed = randi()
			noise_for_temperature.seed =randi()
			noise_for_temperature.frequency = 0.02
			
		#Loop Through Size of the map
			for x in world_size:
				for y in world_size:
					var player_spawn_pos = tile[grass_layer].map_to_local(Vector2i(x,y))	
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
					
					temperature = noise_for_alt.get_noise_2d(x,y)
				
						
					# add noise to arr for check max and min
					noise_arr.append(noise_for_alt.get_noise_2d(x,y))
					
					# Check which terrain to place according to althitude
					# alt in Simplex noise ->(~0.65 to -0.65)
					if sand_alt_max > altitude and altitude > sand_alt_min:
						arr_sand.append(Vector2i(x,y))

					if grass_alt_max > altitude and altitude > grass_alt_min:			
						arr_grass.append(Vector2i(x,y))
					
					#Spawn OBJ on grass Base on temperature
						if  temperature > 0.2 and not Engine.is_editor_hint() and obj:
							var change = randf_range(0,1)
						
							if change >0.95:
								gen_obj(grass_layer,obj,"grass_normal",x,y)
							elif change >0.9:
								gen_obj(grass_layer,obj,"grass_short",x,y)
							elif change >0.8:
								gen_obj(grass_layer,obj,"oak_tree",x,y)
							elif change >0.7:
								gen_obj(grass_layer,obj,"oak_sapling",x,y)
							elif change >0.6:
								gen_obj(grass_layer,obj,"birch_tree",x,y)
									
									
						if  temperature >= 0 and temperature<0.2 and not Engine.is_editor_hint() and obj:
								var change = randf_range(0,1)
								if change >0.8:
									gen_obj(grass_layer,obj,"grass_normal",x,y)
								elif change >0.5:
									gen_obj(grass_layer,obj,"grass_short",x,y)
								elif change >0.45:
									gen_obj(grass_layer,obj,"birch_tree",x,y)
								
									
						if temperature	< 0 and not Engine.is_editor_hint() and obj:
							var change = randf_range(0,1)
							if not Engine.is_editor_hint():
								if change >0.95:
									gen_obj(grass_layer,obj,"small_spruce",x,y)
								elif change > 0.9:
									gen_obj(grass_layer,obj,"spruce_tree",x,y)
									
									
					if 4 > altitude and altitude > -4:
						# Set Sea background
						tile[water_layer].set_cell(Vector2i(x,y),1,Vector2i(9,10))
						arr_water.append(Vector2i(x,y))
						
						
					if not Engine.is_editor_hint() :
						##SPAWN PLAYER	
						if altitude > grass_alt_min and x>world_size/2 and y> world_size/2:
							
							if !isplayer_spawn:
								add_child(player)
								player.position = player_spawn_pos
								isplayer_spawn = true
						###############	



# This Function use for generate node scene 
func gen_obj(layer:int,obj:Dictionary,key:String,x_from_loop:int,y_from_loop:int):
	if tile and obj:
		var object_to_place = obj[key].instantiate() as Node2D
		var tile_pos = tile[layer].map_to_local(Vector2i(x_from_loop,y_from_loop))
		object_to_place.position = tile_pos
		
		## For random size and facing
		var rand_facing = randi_range(0,1)
		var rand_size = randf_range(1.0,max_random_size)
		
		if random_facing:
			if rand_facing:
				object_to_place.scale.x = -1 * rand_size
			else :
				object_to_place.scale.x = 1 * rand_size
				
		if random_size:
			object_to_place.scale.y = rand_size
				
		add_child(object_to_place)
		object_to_place.name = "obj_1"
		
