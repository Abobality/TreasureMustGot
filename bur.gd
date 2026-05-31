extends Entity

@onready var raycast: RayCast2D = $TurretsGun/RayCast2D
@onready var timer: Timer = $Timer
@onready var tower: Sprite2D = $TurretsGun
func _ready() -> void:
	timer.timeout.connect(_on_drill_tick)

func _on_drill_tick() -> void:
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		
		if collider is TileMapLayer:
			var point = raycast.get_collision_point()
			
			var drill_direction = raycast.global_transform.x.normalized()
			
			var check_pos = point + drill_direction * 4.0
			var tile_pos = collider.local_to_map(collider.to_local(check_pos))
			
			var map_node = get_node_or_null("/root/Map")
			if map_node and map_node.has_method("destroy_block"):
				map_node.destroy_block(tile_pos.x, tile_pos.y)

func _on_button_pressed() -> void:
	tower.rotate(1.5708)
