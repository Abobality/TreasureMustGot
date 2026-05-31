extends Enemy

@export var segment_scene: PackedScene 
@export var num_segments: int = 12     
@export var distance_between: float = 12.0 
@export var rotation_speed: float = 3.5
@export var trigger_range: float = 180.0

@onready var head: Area2D = $Head


var segments: Array[Sprite2D] = []
var movement_direction: Vector2 = Vector2.RIGHT
var triggered: bool = false

func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING
	
	for i in range(num_segments):
		var seg = segment_scene.instantiate() as Sprite2D
		$Segments.add_child(seg)
		
		seg.top_level = true 
		
		seg.global_position = global_position
		segments.append(seg)

func _physics_process(delta: float) -> void:
	if not player: return
	
	var distance = global_position.distance_to(player.global_position)
	
	
	if triggered == false and distance < trigger_range:
		triggered = true
	if triggered == false:return
	
	var target_vector = player.global_position - global_position
	var target_angle = target_vector.angle()
	
	rotation = rotate_toward(rotation, target_angle, rotation_speed * delta)

	
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	move_and_slide()
	
	
	update_segments()

func update_segments() -> void:
	var leader_pos = global_position
	
	for i in range(segments.size()):
		var follower = segments[i]
		
		var vector_to_leader = leader_pos - follower.global_position
		var distance = vector_to_leader.length()
		
		
		
		if distance > distance_between:
			var direction = vector_to_leader.normalized()
			var target_pos = leader_pos - direction * distance_between
			
			follower.global_position = follower.global_position.lerp(target_pos, 0.3)
			follower.rotation = lerp_angle(follower.rotation, direction.angle(), 0.3)
		
		leader_pos = follower.global_position

func _on_head_body_entered(body: Node2D) -> void:
	if body is Entity and body.name != "Enemy":
		body.take_damage(1,body.DeathReason.BY_WORM) 
