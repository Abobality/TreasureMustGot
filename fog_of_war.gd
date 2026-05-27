extends Node

@export var tilemapLayer : TileMapLayer
@export var fogOFWar : TileMapLayer

const cell_size = 16

var width = 32
var height = 32
var map_2d = []
var fog_2d = []
var blocks = []

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
	
	map_2d[0][height-1] = 0
	map_2d[width-1][0] = 0
	
	_generator()
	reset_fog_layer()
	redraw_all_terrains()
	reveal_fog_around(width / 2, height / 2)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not tilemapLayer: return
		
		var global_mouse_pos = tilemapLayer.get_global_mouse_position()
		var grid_pos = tilemapLayer.local_to_map(tilemapLayer.to_local(global_mouse_pos))
		
		destroy_block(grid_pos.x, grid_pos.y)
		

func destroy_block(x: int, y: int) -> void:
	if x >= 0 and x < width and y >= 0 and y < height:
		if map_2d[x][y] != 0:
			map_2d[x][y] = 0
			tilemapLayer.erase_cell(Vector2i(x, y))
			reveal_fog_around(x,y)

func redraw_all_terrains() -> void:
	for x in range(width):
		for y in range(height):
			match map_2d[x][y]:
				1:
					tilemapLayer.set_cell(Vector2i(x,y),0,Vector2i(0,0))
				2:
					tilemapLayer.set_cell(Vector2i(x,y),0,Vector2i(2,0))
				3:
					tilemapLayer.set_cell(Vector2i(x,y),0,Vector2i(3,0))
				4:
					tilemapLayer.set_cell(Vector2i(x,y),0,Vector2i(1,0))
				5:
					tilemapLayer.set_cell(Vector2i(x,y),0,Vector2i(1,1))
				6:
					tilemapLayer.set_cell(Vector2i(x,y),0,Vector2i(2,1))
				7:
					tilemapLayer.set_cell(Vector2i(x,y),0,Vector2i(3,1))
	

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
				elif (percentage + noise) < 0.75:
					map_2d[i][j] = _oreGenerator(7,3,25)
				else:
					map_2d[i][j] = _oreGenerator(5,4,15)

func  _oreGenerator(ore,stone,chance):
	var random = randi() % 100 + 1
	
	if random <= chance:
		return ore
	else:
		return stone

func reset_fog_layer():
	if not fogOFWar: return
	fogOFWar.clear()
	for x in range(width):
		for y in range(height):
			fogOFWar.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

func reveal_fog_around(center_x: int, center_y: int) -> void:
	if not fogOFWar: return
	
	# ШАГ 1: Сначала красим внешний радиус (2 клетки вокруг) в полупрозрачный полумрак
	for x in range(center_x - 2, center_x + 3):
		for y in range(center_y - 2, center_y + 3):
			if x >= 0 and x < width and y >= 0 and y < height:
				# Переводим в полумрак только те клетки, которые БЫЛИ в полной тьме
				if fog_2d[x][y] == 0:
					fog_2d[x][y] = 1
					# Рисуем полупрозрачный тайл из атласа (координаты 1, 0)
					fogOFWar.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))

	# ШАГ 2: Красим внутренний радиус (1 клетка вокруг) в полную видимость
	for x in range(center_x - 1, center_x + 2):
		for y in range(center_y - 1, center_y + 2):
			if x >= 0 and x < width and y >= 0 and y < height:
				fog_2d[x][y] = 2
				# Полностью удаляем тайл тумана, чтобы открыть блок
				fogOFWar.erase_cell(Vector2i(x, y))
