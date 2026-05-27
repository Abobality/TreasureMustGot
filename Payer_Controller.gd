extends CharacterBody2D


const SPEED = 30

func _process(delta: float) -> void:
	position.x = clamp(position.x,0,512)
	position.y = clamp(position.y,0,512)

func _physics_process(delta: float) -> void:
	var input = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = input * SPEED
	
	move_and_slide()
