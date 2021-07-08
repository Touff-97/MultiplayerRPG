extends TextureRect

const tool_tip : PackedScene = preload("res://Scenes/SupportScenes/ToolTip.tscn")

onready var gui = get_node("/root/SceneHandler/Map/GUI")


func _ready() -> void:
	connect("mouse_entered", self, "_on_Icon_mouse_entered")
	connect("mouse_exited", self, "_on_Icon_mouse_exited")


func get_drag_data(_position: Vector2):
	var equipment_slot = get_parent().get_name()
	if gui.equipment_data[equipment_slot] != null:
		# Setting the slot's data if it has an item
		var data := {}
		data["origin_node"] = self
		data["origin_panel"] = "Equipment"
		data["origin_item_id"] = gui.equipment_data[equipment_slot]
		data["origin_equipment_slot"] = equipment_slot
		data["origin_max_stack"] = 1
		data["origin_stack"] = 1
		data["origin_texture"] = texture
		
		# Getting the texture to drag around
		var drag_texture = TextureRect.new()
		drag_texture.expand = true
		drag_texture.texture = texture
		drag_texture.rect_size = Vector2(40, 40)
		
		# Parenting the previous texture to a Control node so it can be centered
		var control : Control = Control.new()
		control.add_child(drag_texture)
		drag_texture.rect_position = -0.5 * drag_texture.rect_size
		set_drag_preview(control)
		
		return data


func can_drop_data(_position: Vector2, data) -> bool:
	# Check if the equipment dragged fits into the equipment slot
	var target_equipment_slot = get_parent().get_name()
	if target_equipment_slot == data["origin_equipment_slot"]:
		if gui.equipment_data[target_equipment_slot] == null:
			data["target_item_id"] = null
			data["target_texture"] = null
		else:
			# Swap the currently equipped item when droping a new one
			data["target_item_id"] = gui.equipment_data[target_equipment_slot]
			data["target_texture"] = texture
		return true
	else:
		return false


func drop_data(_position: Vector2, data) -> void:
	var target_equipment_slot = get_parent().get_name()
	var origin_slot = data["origin_node"].get_parent().get_name()
	
	# Update the origin's data
	if data["origin_panel"] == "Inventory":
		gui.inventory_data[origin_slot]["Item"] = data["target_item_id"]
	else:
		gui.equipment_data[origin_slot] = data["target_item_id"]
	
	# Update the origin's texture
	if data["origin_panel"] == "Equipment" and data["target_item_id"] == null:
		var default_texture = load("res://Assets/Inventory/" + origin_slot + "_default_icon.png")
		data["origin_node"].texture = default_texture
	else:
		data["origin_node"].texture = data["target_texture"]
	
	# Update the target's data and texture
	gui.equipment_data[target_equipment_slot] = data["origin_item_id"]
	texture = data["origin_texture"]


func _on_Icon_mouse_entered() -> void:
	var tool_tip_instance = tool_tip.instance()
	tool_tip_instance.origin = "Equipment"
	tool_tip_instance.slot = get_parent().get_name()
	tool_tip_instance.rect_position = get_parent().get_global_transform_with_canvas().origin - Vector2(300, 115)
	
	add_child(tool_tip_instance)
	yield(get_tree().create_timer(0.35), "timeout")
	if has_node("ToolTip") and get_node("ToolTip").valid:
		get_node("ToolTip").show()


func _on_Icon_mouse_exited() -> void:
	get_node("ToolTip").free()
