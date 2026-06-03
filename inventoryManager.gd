extends Node

signal inventory_changed

var inventory: Dictionary = {}
var item_textures: Dictionary = {
	"wood": preload("res://chest.png"),  
	"stone": preload("res://chest.png"),
	"iron": preload("res://chest.png"),
	"turret": preload("res://chest.png")
}

func add_item(item_id: String, amount: int = 1) -> void:
	if inventory.has(item_id):
		inventory[item_id] += amount
	else:
		inventory[item_id] = amount
	inventory_changed.emit()

func remove_item(item_id: String, amount: int = 1) -> bool:
	if get_item_count(item_id) >= amount:
		inventory[item_id] -= amount
		if inventory[item_id] <= 0:
			inventory.erase(item_id) 
		inventory_changed.emit()
		return true
	return false 

func get_item_count(item_id: String) -> int:
	return inventory.get(item_id, 0) 


var recipes: Dictionary = {
	"turret": {
		"iron": 5, 
		"stone": 2
	},
	"drill": {
		"iron": 10,
		"gear": 3
	},
	"gear": {
		"iron": 2
	}
}

func can_craft(recipe_id: String) -> bool:
	if not recipes.has(recipe_id):
		return false
		
	var ingredients = recipes[recipe_id]
	
	for item_id in ingredients:
		var amount_needed = ingredients[item_id]
		if get_item_count(item_id) < amount_needed:
			return false
			
	return true

func craft(recipe_id: String) -> bool:
	if can_craft(recipe_id):
		var ingredients = recipes[recipe_id]
		
		for item_id in ingredients:
			var amount_to_remove = ingredients[item_id]
			remove_item(item_id, amount_to_remove)
			
		add_item(recipe_id, 1)
		print("Скрафчено: ", recipe_id)
		return true
		
	print("Не хватает ресурсов для: ", recipe_id)
	return false
