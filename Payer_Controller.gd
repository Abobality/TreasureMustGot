extends Entity

const BULLET_SCENE = preload("res://bullet.tscn")


func _physics_process(_delta: float) -> void:
	var input = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = input * speed
	move_and_slide()

func  _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_buikd_mode"):
		shoot()


func shoot():
	var map_node = get_node_or_null("/root/GameManager/GameWorld/Map")
	
	if map_node and map_node.has_method("spawn_bullet"):
		var dir = (get_global_mouse_position() - global_position).normalized()
		var start_pos = global_position + dir * 10.0
		
		map_node.spawn_bullet(start_pos, dir, self)
		
