extends TextureRect

const tool_tip : PackedScene = preload("res://Scenes/SupportScenes/ToolTip.tscn")
const split_popup : PackedScene = preload("res://Scenes/SupportScenes/ItemSplitPopup.tscn")

onready var gui = get_node("/root/SceneHandler/Map/GUI")


func get_drag_data(_position: Vector2):
	var hotbar_slot = get_parent().get_name()
	if gui.hotbar_data[hotbar_slot]["Item"] != null:
		# Setting the slot's data if it has an item
		var data := {}
		data["origin_node"] = self
		data["origin_panel"] = "Hotbar"
		data["origin_item_id"] = gui.hotbar_data[hotbar_slot]["Item"]
		data["origin_equipment_slot"] = gui.item_data[str(gui.hotbar_data[hotbar_slot]["Item"])]["EquipmentSlot"]
		data["origin_max_stack"] = gui.item_data[str(gui.hotbar_data[hotbar_slot]["Item"])]["Stack"]
		data["origin_stack"] = gui.hotbar_data[hotbar_slot]["Stack"]
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
	var target_inv_slot = get_parent().get_name()
	if gui.hotbar_data[target_inv_slot]["Item"] == null:
		data["target_item_id"] = null
		data["target_texture"] = null
		data["target_stack"] = null
		data["target_max_stack"] = null
		return true
	else:
		# Swap the currently equipped item when droping a new one
		if Input.is_action_pressed("secondary"):
			return false
		else:
			data["target_item_id"] = gui.hotbar_data[target_inv_slot]["Item"]
			data["target_texture"] = texture
			data["target_stack"] = gui.hotbar_data[target_inv_slot]["Stack"]
			data["target_max_stack"] = gui.item_data[str(gui.hotbar_data[target_inv_slot]["Item"])]["Stack"]
			if data["origin_panel"] == "Equipment":
				var target_equipment_slot = gui.item_data[str(gui.hotbar_data[target_inv_slot]["Item"])]["EquipmentSlot"]
				if target_equipment_slot == data["origin_equipment_slot"]:
					return true
				else:
					return false
			else:
				# data["origin_panel"] = "Hotbar"
				return true


### Bugs
# When dropping from hotbar to inventory, the origin data doesn't become null
# Can't divide stacks between the inventory and hotbar

func drop_data(_position: Vector2, data) -> void:
	var target_inventory_slot = get_parent().get_name()
	var origin_slot = data["origin_node"].get_parent().get_name()
	
	if data["origin_node"] == self:
		pass
	elif Input.is_action_pressed("secondary") and data["origin_panel"] == "Hotbar" and data["origin_stack"] > 1:
		var split_popup_instance = split_popup.instance()
		split_popup_instance.rect_position = get_parent().get_global_transform_with_canvas().origin - Vector2(250, 90)
		split_popup_instance.data = data
		add_child(split_popup_instance)
		get_node("ItemSplitPopup").show()
	else:
		# Update the origin's data
		if data["target_item_id"] == data["origin_item_id"] and data["target_max_stack"] > 1 and (data["origin_stack"] + data["target_stack"]) <= data["target_max_stack"]:
			if data["origin_panel"] == "Hotbar":
				gui.hotbar_data[origin_slot]["Item"] = null
				gui.hotbar_data[origin_slot]["Stack"] = null
			elif data["origin_panel"] == "Inventory":
				gui.inventory_data[origin_slot]["Item"] = null
				gui.inventory_data[origin_slot]["Stack"] = null
		# Elif statement with a difference in stack greater than the max stack = texture is the same, stack label = (origin_stack + target_stack) - max_stack
		elif data["target_item_id"] == data["origin_item_id"] and data["target_max_stack"] > 1 and (data["origin_stack"] + data["target_stack"]) > data["target_max_stack"]:
			if data["origin_panel"] == "Hotbar":
				gui.hotbar_data[origin_slot]["Stack"] = (data["origin_stack"] + data["target_stack"]) - data["target_max_stack"]
			elif data["origin_panel"] == "Inventory":
				gui.inventory_data[origin_slot]["Stack"] = (data["origin_stack"] + data["target_stack"]) - data["target_max_stack"]
		elif data["origin_panel"] == "Hotbar":
			gui.hotbar_data[origin_slot]["Item"] = data["target_item_id"]
			gui.hotbar_data[origin_slot]["Stack"] = data["target_stack"]
		elif data["origin_panel"] == "Inventory":
			gui.inventory_data[origin_slot]["Item"] = data["target_item_id"]
			gui.inventory_data[origin_slot]["Stack"] = data["target_stack"]
		else:
			gui.equipment_data[origin_slot] = data["target_item_id"]
		
		# Update the origin's texture and label
		if data["target_item_id"] == data["origin_item_id"] and data["target_max_stack"] > 1 and (data["origin_stack"] + data["target_stack"]) <= data["target_max_stack"]:
			data["origin_node"].texture = null
			data["origin_node"].get_node("../Stack").set_text("")
		# Elif statement with a difference in stack greater than the max stack = texture is the same, stack label = (origin_stack + target_stack) - max_stack
		elif data["target_item_id"] == data["origin_item_id"] and data["target_max_stack"] > 1 and (data["origin_stack"] + data["target_stack"]) > data["target_max_stack"]:
			data["origin_node"].get_node("../Stack").set_text(str((data["origin_stack"] + data["target_stack"]) - data["target_max_stack"]))
		elif data["origin_panel"] == "Equipment" and data["target_item_id"] == null:
			var default_texture = load("res://Assets/Inventory/" + origin_slot + "_default_icon.png")
			data["origin_node"].texture = default_texture
		else:
			data["origin_node"].texture = data["target_texture"]
			if data["target_stack"] != null and data["target_stack"] > 1:
				data["origin_node"].get_node("../Stack").set_text(str(data["target_stack"]))
			elif data["origin_panel"] != "Equipment":
				data["origin_node"].get_node("../Stack").set_text("")
		
		# Update the target's data and texture
		if data["target_item_id"] == data["origin_item_id"] and data["target_max_stack"] > 1 and (data["origin_stack"] + data["target_stack"]) <= data["target_max_stack"]:
			var new_stack = data["target_stack"] + data["origin_stack"]
			gui.hotbar_data[target_inventory_slot]["Stack"] = new_stack
			get_node("../Stack").set_text(str(new_stack))
		# Elif statement with a difference in stack greater than the max stack = texture is the same, stack label = max stack
		elif data["target_item_id"] == data["origin_item_id"] and data["target_max_stack"] > 1 and (data["origin_stack"] + data["target_stack"]) > data["target_max_stack"]:
			var new_stack = data["target_max_stack"]
			gui.hotbar_data[target_inventory_slot]["Stack"] = data["target_max_stack"]
			get_node("../Stack").set_text(str(new_stack))
		else:
			gui.hotbar_data[target_inventory_slot]["Item"] = data["origin_item_id"]
			texture = data["origin_texture"]
			gui.hotbar_data[target_inventory_slot]["Stack"] = data["origin_stack"]
			if data["origin_stack"] != null and data["origin_stack"] > 1:
				get_node("../Stack").set_text(str(data["origin_stack"]))
			else:
				get_node("../Stack").set_text("")


func SplitStack(split_amount: int, data: Dictionary) -> void:
	var target_inv_slot = get_parent().get_name()
	var origin_slot = data["origin_node"].get_parent().get_name()
	
	gui.hotbar_data[origin_slot]["Stack"] = data["origin_stack"] - split_amount
	gui.hotbar_data[target_inv_slot]["Item"] = data["origin_item_id"]
	gui.hotbar_data[target_inv_slot]["Stack"] = split_amount
	texture = data["origin_texture"]
	
	if data["origin_stack"] - split_amount > 1:
		data["origin_node"].get_node("../Stack").set_text(str(data["origin_stack"] - split_amount))
	else:
		data["origin_node"].get_node("../Stack").set_text("")
	
	if split_amount > 1:
		get_node("../Stack").set_text(str(split_amount))
	else:
		get_node("../Stack").set_text("")


func _on_Icon_mouse_entered() -> void:
	var tool_tip_instance = tool_tip.instance()
	tool_tip_instance.origin = "Hotbar"
	tool_tip_instance.slot = get_parent().get_name()
	
	tool_tip_instance.rect_position = get_parent().get_global_transform_with_canvas().origin - Vector2(255, 240)
	add_child(tool_tip_instance)
	yield(get_tree().create_timer(0.35), "timeout")
	if has_node("ToolTip") and get_node("ToolTip").valid:
		get_node("ToolTip").show()


func _on_Icon_mouse_exited() -> void:
	get_node("ToolTip").free()
