extends ColorRect

const hotbar_slot : PackedScene = preload("res://Scenes/SupportScenes/HotbarSlot.tscn")

onready var gui = get_node("/root/SceneHandler/Map/GUI")
onready var hotbar = $Margin/HBox


func _ready() -> void:
	for i in gui.hotbar_data.keys():
		var new_hotbar_slot = hotbar_slot.instance()
		if gui.hotbar_data[i]["Item"] != null:
			var item_name = gui.item_data[str(gui.hotbar_data[i]["Item"])]["Name"]
			var icon_texture = load("res://Assets/Items/" + item_name + ".png")
			new_hotbar_slot.get_node("Icon").set_texture(icon_texture)
			var item_stack = gui.hotbar_data[i]["Stack"]
			if item_stack != null and item_stack > 1:
				new_hotbar_slot.get_node("Stack").set_text(str(item_stack))
		hotbar.add_child(new_hotbar_slot, true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Hotbar1"):
		get_node("Margin/Selected").rect_position.x = 5
	if event.is_action_pressed("Hotbar2"):
		get_node("Margin/Selected").rect_position.x = 50
	if event.is_action_pressed("Hotbar3"):
		get_node("Margin/Selected").rect_position.x = 95
	if event.is_action_pressed("Hotbar4"):
		get_node("Margin/Selected").rect_position.x = 140
	if event.is_action_pressed("Hotbar5"):
		get_node("Margin/Selected").rect_position.x = 185
	if event.is_action_pressed("Hotbar6"):
		get_node("Margin/Selected").rect_position.x = 230
	if event.is_action_pressed("Hotbar7"):
		get_node("Margin/Selected").rect_position.x = 275
	if event.is_action_pressed("Hotbar8"):
		get_node("Margin/Selected").rect_position.x = 320
	
	if event.is_action_pressed("scroll_up"):
		if get_node("Margin/Selected").rect_position.x < 320:
			get_node("Margin/Selected").rect_position.x += 45
		else:
			get_node("Margin/Selected").rect_position.x = 5
	if event.is_action_pressed("scroll_down"):
		if get_node("Margin/Selected").rect_position.x > 5:
			get_node("Margin/Selected").rect_position.x -= 45
		else:
			get_node("Margin/Selected").rect_position.x = 320
	
