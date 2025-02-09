
extends Node2D
class_name World_gen
##Generate Button

##Generation Setting Inspector
@export_group("Generation Setting")
@export_range(10,1000,10) var world_size:float =50
@export var use_falloff  : bool=true
@export var use_temperature  : bool=true
@export_range(0,3) var Falloff_multiplier : float = 1.7
@export var altitude_noise : FastNoiseLite = FastNoiseLite.new()
@export var temperature_noise : FastNoiseLite = FastNoiseLite.new()
@export var precipitation_noise : FastNoiseLite = FastNoiseLite.new()
@export var tile : Array[TileMapLayer]
var alt_noise_arr:Array =[]
var tmp_noise_arr:Array =[]
var precip_noise_arr:Array =[]
var arr_water =[]
var arr_sand =[]
var arr_grass =[]
var arr_stone =[]
#############################################
##LAYERS and Altitude Inspector
@export_group("Layer and Altitude")
@export_subgroup("water")
@export var water_layer:int = 0
@export_range(-1,1) var water_alt_max:float = 0
@export_range(-1,1) var water_alt_min:float = -1

@export_subgroup("sand")
@export var sand_layer:int = 1
@export_range(-1,1) var sand_alt_max:float = 1
@export_range(-1,1) var sand_alt_min:float = -0.4

@export_subgroup("grass")
@export var grass_layer:int = 2
@export_range(-1,1) var grass_alt_max:float =  1
@export_range(-1,1) var grass_alt_min:float =  -0.3

@export_subgroup("stone")
@export var stone_layer:int = 3
@export_range(-1,1) var stone_alt_max:float =  0
@export_range(-1,1) var stone_alt_min:float =  -0.25
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
	if not tile or not obj:
		print("No tile or object data provided!")
		return
		
	clear()
	while not isplayer_spawn:
		gen_world()
		gen_tile()
	pass

func clear():
	if not tile:
		return
	alt_noise_arr.clear()
	tmp_noise_arr.clear()
	precip_noise_arr.clear()
	
	for x in world_size:
		for y in world_size:
			for layer in tile:
				layer.erase_cell(Vector2i(x,y))
	arr_grass.clear()
	arr_sand.clear()
	arr_stone.clear()
	arr_water.clear()
	
''' OLD CODE UNUSED
#Clear tile from PREVIOUS generation
func clear():
	if tile and obj:
		alt_noise_arr.clear()
		tmp_noise_arr.clear()
		precip_noise_arr.clear()
		for x in 1000:
			for y in 1000:
				tile[0].erase_cell(Vector2i(x,y))
				tile[1].erase_cell(Vector2i(x,y))
				tile[2].erase_cell(Vector2i(x,y))
				tile[3].erase_cell(Vector2i(x,y))
				tile[water_layer].set_cell(Vector2i(x,y),-1,Vector2i(-1,-1))
				tile[sand_layer].set_cell(Vector2i(x,y),-1,Vector2i(-1,-1))
				tile[grass_layer].set_cell(Vector2i(x,y),-1,Vector2i(-1,-1))
				tile[stone_layer].set_cell(Vector2i(x,y),-1,Vector2i(-1,-1))
		tile[grass_layer].set_cells_terrain_connect(arr_grass,2,-1)
		tile[sand_layer].set_cells_terrain_connect(arr_sand,1,-1)
		tile[water_layer].set_cells_terrain_connect(arr_water,0,-1)
		tile[stone_layer].set_cells_terrain_connect(arr_stone,0,-1)
		arr_water.clear()
		arr_sand.clear()
		arr_grass.clear()
'''
	#set_cells_terrain_connect(arr,terrain_set,terrain)
func gen_tile():
	if tile and obj:	
		tile[stone_layer].set_cells_terrain_connect(arr_stone,3,0)
		tile[grass_layer].set_cells_terrain_connect(arr_grass,2,0)
		tile[sand_layer].set_cells_terrain_connect(arr_sand,1,0)
		tile[water_layer].set_cells_terrain_connect(arr_water,0,0)
		


func  gen_world():
	if tile and obj:
		precipitation_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		if altitude_noise == null:
			print("must assign altitude noise")
		elif temperature_noise == null:
			print("must assign temperature noise")
		elif precipitation_noise == null:
			print("must assign precipitation noise")
		else:
			altitude_noise.seed = randi()
			temperature_noise.seed =randi()
			precipitation_noise.seed =randi()
			
			temperature_noise.frequency = 0.0195
			precipitation_noise.frequency = 0.0195
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
					var precipitation
					
					if use_falloff:
						altitude = ((altitude_noise.get_noise_2d(x,y))-(distance*Falloff_multiplier))
					else:
						altitude = (altitude_noise.get_noise_2d(x,y))
					
					temperature = ((temperature_noise.get_noise_2d(x,y) *100)/2.6)+10
					precipitation = ((precipitation_noise.get_noise_2d(x,y) *1000)+600)/4
						
					# add noise to arr for check max and min
					alt_noise_arr.append(altitude)
					tmp_noise_arr.append(temperature)
					precip_noise_arr.append(precipitation)
					# Check which terrain to place according to althitude
					# alt in Simplex noise ->(~0.65 to -0.65)
					if sand_alt_max > altitude and altitude > sand_alt_min:
						arr_sand.append(Vector2i(x,y))
					if grass_alt_max > altitude and altitude > grass_alt_min:			
						arr_grass.append(Vector2i(x,y))
						var change = randi_range(1,3)
						match change:
							1:
								if temperature >= 0 and temperature <= 20:
									gen_biome_obj("grass land",precipitation,x,y)
							2:
								if temperature >= 5 and temperature <= 22 :
									gen_biome_obj("boadleaf",precipitation,x,y)
							3:
								if temperature >= 0 and temperature <= 10 :
									gen_biome_obj("taiga",precipitation,x,y)
					if stone_alt_max > altitude and altitude > stone_alt_min and temperature > 25:
						arr_stone.append(Vector2i(x,y))
					
					if altitude:
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
	print("max alt = ",alt_noise_arr.max()," | min alt = ",alt_noise_arr.min())
	print("max temp = ",tmp_noise_arr.max()," | min temp = ",tmp_noise_arr.min())
	print("max precip = ",precip_noise_arr.max()," | min precip = ",precip_noise_arr.min())
func gen_biome_obj(biome:String,precipitation,x,y):
	biome = biome.to_lower()
	#Spawn OBJ on grass Base on temperature
	if biome == "grass land":
		#Grass land Biome			
		if precipitation < 140 and precipitation >= 100:
			var change = randf_range(0,1)
			if change >0.8:
				gen_obj(grass_layer,obj,"grass_normal",x,y)
			elif change >0.5:
				gen_obj(grass_layer,obj,"grass_short",x,y)
			elif change >0.45:
				gen_obj(grass_layer,obj,"birch_tree",x,y)
				
	if biome == "taiga":
		#Taiga Biome	
		if precipitation < 100:
			var change = randf_range(0,1)
			if change >0.9:
				gen_obj(grass_layer,obj,"small_spruce",x,y)
			elif change > 0.8:
				gen_obj(grass_layer,obj,"spruce_tree",x,y)
		
	if biome == "boadleaf":
		#Boadleaf forest Biome	
		if precipitation < 250 and precipitation > 140:
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
	pass
	
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
		
