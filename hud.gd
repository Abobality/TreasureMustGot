extends CanvasLayer

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var list_container: VBoxContainer = $Inventory
@onready var health_label: Label = $Label

var player_node: CharacterBody2D # Кэшируем игрока

func _ready() -> void:
	await get_tree().process_frame
	
	InventoryManager.add_item("wood", 15)
	InventoryManager.add_item("stone", 15)
	InventoryManager.add_item("iron", 16)
	InventoryManager.add_item("turret", 15)
	var map_node = get_tree().current_scene.find_child("Map", true, false)
	if map_node and sub_viewport:
		sub_viewport.world_2d = map_node.get_world_2d()
	else:
		print("HUD Ошибка: Не удалось найти сцену /root/Map!")

	# 2. Ищем и запоминаем игрока один раз
	var found_player = get_tree().current_scene.find_child("player", true, false)
	if found_player is CharacterBody2D:
		player_node = found_player
		
	# 3. Настраиваем инвентарь
	InventoryManager.inventory_changed.connect(_update_inventory_ui)
	_update_inventory_ui()

func _process(_delta: float) -> void:
	# Безопасное обновление здоровья: проверяем, существует ли еще игрок
	if is_instance_valid(player_node):
		health_label.text = "Current health: " + str(player_node.current_health)
func _update_inventory_ui() -> void:
	# 1. ОЧИСТКА: Удаляем старые строчки, чтобы они не дублировались
	for child in list_container.get_children():
		child.queue_free()
	
	# 2. ОТРИСОВКА: Пробегаемся по словарю нашего инвентаря
	for item_id in InventoryManager.inventory:
		var amount = InventoryManager.inventory[item_id]
		
		# Создаем горизонтальный контейнер для ОДНОЙ строчки: [Спрайт] [Количество]
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10) # Зазор между спрайтом и текстом
		
		# Создаем узел UI-спрайта
		var sprite_rect = TextureRect.new()
		
		# Проверяем, загружен ли у нас спрайт для этого ID
		if InventoryManager.item_textures.has(item_id):
			sprite_rect.texture = InventoryManager.item_textures[item_id]
		
		# НАСТРОЙКА РАЗМЕРА СПРАЙТА (чтобы картинка не растянулась на пол-экрана)
		sprite_rect.custom_minimum_size = Vector2(32, 32) # Жесткий размер иконки в пикселях
		sprite_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# Создаем текст с количеством предметов
		var count_label = Label.new()
		count_label.text = "x " + str(amount)
		
		# Собираем строчку: добавляем в неё спрайт и текст
		row.add_child(sprite_rect)
		row.add_child(count_label)
		
		# Добавляем готовую строчку в наш главный вертикальный список
		list_container.add_child(row)


func _on_button_pressed() -> void:
	if InventoryManager.craft("turret"):
		print("Турель успешно создана!")
		# Здесь можно заспавнить турель на мышку, чтобы игрок её поставил
	else:
		print("Мало железа или меди!")
