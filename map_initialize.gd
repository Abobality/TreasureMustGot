extends Node

@export var tilemapLayer : TileMapLayer
@export var fogOFWar : TileMapLayer
@export_group("Object Pool")
@export var pool_size: int = 50 

const cell_size = 16
const enemy_scene = preload("res://Enemy.tscn")
const colodec_scene = preload("res://colodec.tscn")
const chest_scene = preload("res://chest.tscn")
const bullet_scene = preload("res://bullet.tscn")

var bullet_pool: Array[Hitbox] = []
var width = 32
var height = 32
var map_2d = []
var fog_2d = []
var blocks = []
var astar = AStar2D.new()

func _ready():
	for i in width:
		var row = []
		row.resize(height)
		row.fill(1) 
		map_2d.append(row)
	
	for i in width:
		var row = []
		row.resize(height)
		row.fill(0) 
		fog_2d.append(row)
		
	for i in width:
		var row = []
		row.resize(height)
		row.fill(0) 
		blocks.append(row)
	
	map_2d[0][height-1] = 0
	map_2d[width-1][0] = 0
	
	init_bullet_pool()
	_generator()
	reset_fog_layer()
	stamp_sub_array(map_2d,Dungeons.camp_zone,6,20)
	
	redraw_all_terrains()
	
	reveal_fog_around(width-1,0)
	reveal_fog_around(0,height-1)
	update_navigation_grid()
	_generate_borders()

		

func destroy_block(x: int, y: int) -> void:
	if x >= 0 and x < width and y >= 0 and y < height:
		if map_2d[x][y] != 0:
			blocks[x][y] -= 1
			if blocks[x][y] <= 0:
				map_2d[x][y] = 0
				tilemapLayer.erase_cell(Vector2i(x, y))
				var broken_block_id = get_id_by_pos(x, y)
				if astar.has_point(broken_block_id):
					astar.set_point_disabled(broken_block_id, false)
				reveal_fog_around(x,y)
			

func redraw_all_terrains() -> void:
	for x in range(width):
		for y in range(height):
			match map_2d[x][y]:
				1:
					tilemapLayer.set_cell(Vector2i(x,y),0,Vector2i(0,0))
					blocks[x][y] = 1
				2:
					tilemapLayer.set_cell(Vector2i(x,y),0,Vector2i(2,0))
					blocks[x][y] = 3
				3:
					tilemapLayer.set_cell(Vector2i(x,y),0,Vector2i(3,0))
					blocks[x][y] = 6
				4:
					tilemapLayer.set_cell(Vector2i(x,y),0,Vector2i(1,0))
					blocks[x][y] = 9
				5:
					tilemapLayer.set_cell(Vector2i(x,y),0,Vector2i(1,1))
					blocks[x][y] = 6
				6:
					tilemapLayer.set_cell(Vector2i(x,y),0,Vector2i(2,1))
					blocks[x][y] = 9
				7:
					tilemapLayer.set_cell(Vector2i(x,y),0,Vector2i(3,1))
					blocks[x][y] = 12

func _generator():
	var max_diagonal = float((width - 1) + (height - 1))
	
	for i in range(width):
		for j in range(height):
			var diagonal_value = i + ((height - 1) - j)
			var percentage = float(diagonal_value) / max_diagonal

			if map_2d[i][j] != 0:
				var noise = randf_range(-0.07, 0.07)
				if (percentage + noise) < 0.25:
					map_2d[i][j] = 1
				elif (percentage + noise) < 0.5:
					map_2d[i][j] = _oreGenerator(6,2,40)
					_spawnActivity(enemy_scene,i,j,5)
					_spawnActivity(colodec_scene,i,j,1)
				elif (percentage + noise) < 0.75:
					map_2d[i][j] = _oreGenerator(7,3,25)
				else:
					map_2d[i][j] = _oreGenerator(5,4,15)
					_spawnActivity(colodec_scene,i,j,1)
					_spawnActivity(chest_scene,i,j,1)

func  _oreGenerator(ore,stone,chance):
	var random = randi() % 100 + 1
	
	if random <= chance:
		return ore
	else:
		return stone

func _spawnActivity(packedScene: PackedScene,x,y,chance):
	var random = randi() % 100 + 1
	var dungeon_center = Vector2(8,22)
	var current_cell = Vector2(x,y)
	
	if current_cell.distance_to(dungeon_center) <=5.0 or map_2d[x][y] == 0:
		return
		
	if random <= chance:
		var activity = packedScene.instantiate()
		if activity.is_in_group("Enemy"):
			activity.player = $player
			activity.map_node = $/root/GameManager/GameWorld/Map
		add_child(activity)
		activity.global_position = Vector2(x*16+8,y*16+8)

func reset_fog_layer():
	if not fogOFWar: return
	fogOFWar.clear()
	for x in range(width):
		for y in range(height):
			fogOFWar.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

func reveal_fog_around(center_x: int, center_y: int) -> void:
	if not fogOFWar: return
	
	for x in range(center_x - 2, center_x + 3):
		for y in range(center_y - 2, center_y + 3):
			if x >= 0 and x < width and y >= 0 and y < height:
				if fog_2d[x][y] == 0:
					fog_2d[x][y] = 1
					fogOFWar.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))

	for x in range(center_x - 1, center_x + 2):
		for y in range(center_y - 1, center_y + 2):
			if x >= 0 and x < width and y >= 0 and y < height:
				fog_2d[x][y] = 2
				fogOFWar.erase_cell(Vector2i(x, y))


func stamp_sub_array(map_array: Array, stamp_array: Array, offset_x: int, offset_y: int):
	var stamp_width = stamp_array.size()
	if stamp_width == 0: return
	var stamp_height = stamp_array[0].size()
	
	for i in range(stamp_width):
		for j in range(stamp_height):
			var target_x = offset_x + i
			var target_y = offset_y + j
			
			if target_x >= 0 and target_x < width and target_y >= 0 and target_y < height:
				map_array[target_x][target_y] = stamp_array[i][j]
				reveal_fog_around(target_x,target_y)


func get_id_by_pos(x: int, y: int) -> int:
	return x + y * width

func update_navigation_grid():
	astar.clear()
	for x in range(width):
		for y in range(height):
			var id = get_id_by_pos(x, y)
			var world_pos = Vector2(x * cell_size + cell_size/2, y * cell_size + cell_size/2)
			astar.add_point(id, world_pos)
			
			if map_2d[x][y] != 0:
				astar.set_point_disabled(id, true)
	
	for x in range(width):
		for y in range(height):
			var current_id = get_id_by_pos(x, y)
			if x + 1 < width:
				astar.connect_points(current_id, get_id_by_pos(x+1, y))
			if y + 1 < height:
				astar.connect_points(current_id, get_id_by_pos(x, y+1))

func init_bullet_pool() -> void:
	for i in range(pool_size):
		var bullet = enemy_scene.instantiate() as Hitbox
		var bullet_instance = bullet_scene.instantiate() as Hitbox
		
		bullet_instance.visible = false
		bullet_instance.set_process(false)
		bullet_instance.set_physics_process(false)
		bullet_instance.monitoring = false
		bullet_instance.monitorable = false
		
		add_child(bullet_instance)
		bullet_pool.append(bullet_instance)

func spawn_bullet(start_pos: Vector2, dir: Vector2, bullet_creator: Node2D) -> void:
	var bullet: Hitbox = null
	for b in bullet_pool:
		if not b.visible: 
			bullet = b
			break
			
	if bullet == null:
		bullet = bullet_scene.instantiate() as Hitbox
		bullet.visible = false
		add_child(bullet)
		bullet_pool.append(bullet)
		
	bullet.creator = bullet_creator
	bullet.global_position = start_pos
	bullet.direction = dir
	
	bullet.visible = true
	bullet.set_process(true)
	bullet.set_physics_process(true)
	bullet.set_deferred("monitoring", true)
	bullet.set_deferred("monitorable", true)

func _generate_borders(thickness: int = 15) -> void:
	for x in range(-thickness, width + thickness):
		for y in range(-thickness, height + thickness):
			
			if x < 0 or x >= width or y < 0 or y >= height:
				
				tilemapLayer.set_cell(Vector2i(x, y), 0, Vector2i(2, 0))
				
				if fogOFWar:
					fogOFWar.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
