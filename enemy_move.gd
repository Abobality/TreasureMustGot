extends Enemy


var is_attacking: bool = false

var frames_since_update: int = 0
var update_interval: int = 30 

var current_path: PackedVector2Array = []
var path_index: int = 0

func  _ready() -> void:
	frames_since_update = randi_range(0, 15)

func _physics_process(_delta: float) -> void:
	if not player or not map_node: return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player < 6.0:
		start_attack()
	else:
		frames_since_update += 1
		if frames_since_update >= update_interval:
			frames_since_update = 0
			make_path_to_player()
			
		
		if current_path.size() > 0 and path_index < current_path.size():
			var target_pos = current_path[path_index]
			
			
			if global_position.distance_to(target_pos) < 4.0:
				path_index += 1
			else:
				var direction = (target_pos - global_position).normalized()
				velocity = direction * speed
				move_and_slide()
		else:
			velocity = Vector2.ZERO

func make_path_to_player():
	var tilemap = map_node.tilemapLayer
	var start_grid = tilemap.local_to_map(tilemap.to_local(global_position))
	var end_grid = tilemap.local_to_map(tilemap.to_local(player.global_position))
	
	var start_id = map_node.get_id_by_pos(start_grid.x, start_grid.y)
	var end_id = map_node.get_id_by_pos(end_grid.x, end_grid.y)
	
	if map_node.astar.has_point(start_id) and map_node.astar.has_point(end_id):
		current_path = map_node.astar.get_point_path(start_id, end_id)
		path_index = 0 

func start_attack():
	is_attacking = true
	velocity = Vector2.ZERO 
	$AnimationPlayer.play("attack")
	
	
	await $AnimationPlayer.animation_finished
	is_attacking = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Entity and body.name == "player": 
		body.take_damage(1,body.DeathReason.BY_ENEMY)
