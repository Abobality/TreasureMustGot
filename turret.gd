extends Entity

@onready var gun: Sprite2D = $TurretsGun
@onready var detection_area: Area2D = $Area2D 
@onready var timer: Timer = $Timer 
@export var player: Node2D

var current_target: Node2D = null
var can_shoot: bool = true

func _ready() -> void:
	timer.wait_time = 0.6 
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _process(_delta: float) -> void:
	if not is_instance_valid(current_target) or not current_target.get_node("Head") in detection_area.get_overlapping_areas():
		current_target = find_closest_target()
	
	if current_target:
		gun.look_at(current_target.global_position)
		if can_shoot:
			shoot_at_target(current_target.global_position)

func find_closest_target() -> Node2D:
	var targets = detection_area.get_overlapping_areas()
	var closest: Node2D = null
	var min_dist = INF
	
	for area in targets:
		var potential_enemy = area.get_parent()
		
		if potential_enemy is Enemy and potential_enemy != self:
			var dist = global_position.distance_to(potential_enemy.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = potential_enemy
				
	return closest

func shoot_at_target(target_pos: Vector2) -> void:
	var map_node = get_node_or_null("/root/Map")
	if map_node and map_node.has_method("spawn_bullet") :
		can_shoot = false
		
		var dir = (target_pos - gun.global_position).normalized()
		var start_pos = gun.global_position + dir * 16.0
		
		map_node.spawn_bullet(start_pos, dir, self)

func _on_timer_timeout() -> void:
	can_shoot = true 
