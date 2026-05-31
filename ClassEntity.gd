class_name  Entity
extends CharacterBody2D

@export var max_health: int = 5
@export var speed:float = 60.0

enum DeathReason {
	BY_ENEMY,      #
	BY_WORM, 
	BY_SELF,      
	BY_EXPLOSION,  
	UNKNOWN        
}

var current_health: int

func _ready() -> void:
	current_health = max_health


func take_damage(damage: int, reason: DeathReason = DeathReason.UNKNOWN) -> void:
	current_health -= damage
	print("Игрок получил урон. Осталось здоровья: ", current_health)
	
	if current_health <= 0:
		die(reason)

func die(reason: DeathReason) -> void:
	print("Игрок погиб!")
	
	match reason:
		DeathReason.BY_ENEMY:
			print("Причина: Убит рядовым противником.")
		DeathReason.BY_WORM:
			print("Причина: Сжеван гигантским червем!")
		DeathReason.BY_EXPLOSION:
			print("Причина: Подорвался на бочке.")
		DeathReason.BY_SELF:
			print("Причина: Решил покинуть бренный мир.")
		DeathReason.UNKNOWN:
			print("Причина смерти туманна...")
			
	queue_free()
	
