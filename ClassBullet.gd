class_name Hitbox
extends Area2D

@export var speed: float = 300.0

var direction: Vector2 = Vector2.ZERO
var creator: Node2D

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if not visible: return
	
	if body is TileMapLayer:
		var tilemap_layer = body
		var check_pos = global_position + direction * 8.0 
		var grid_pos = tilemap_layer.local_to_map(tilemap_layer.to_local(check_pos))
		var map_node = get_node_or_null("/root/GameManager/GameWorld/Map") 
		
		if map_node and map_node.has_method("destroy_block"):
			map_node.destroy_block(grid_pos.x, grid_pos.y)
			
		deactivate()
		return
		
	if body.has_method("take_damage") and body != creator:
		if "DeathReason" in body:
			body.take_damage(1, body.DeathReason.BY_SELF)
		else:
			body.take_damage(1)
		
	deactivate()

func deactivate() -> void:
	visible = false
	set_process(false)
	set_physics_process(false)
	
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	direction = Vector2.ZERO
	creator = null
