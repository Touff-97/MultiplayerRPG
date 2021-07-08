extends Popup

onready var gui = get_node("/root/SceneHandler/Map/GUI")

var origin : String = ""
var slot : String = ""
var valid : bool = false


func _ready() -> void:
	var item_id
	if origin == "Inventory":
		if gui.inventory_data[slot]["Item"] != null:
			item_id = str(gui.inventory_data[slot]["Item"])
			valid = true
	elif origin == "Hotbar":
		if gui.hotbar_data[slot]["Item"] != null:
			item_id = str(gui.hotbar_data[slot]["Item"])
			valid = true
	else:
		if gui.equipment_data[slot] != null:
			item_id = str(gui.equipment_data[slot])
			valid = true
	
	if valid:
		get_node("Background/Margin/VBox/ItemName").set_text(gui.item_data[item_id]["Name"])
		var item_stat := 1
		for i in range(gui.item_stats.size()):
			var stat_name = gui.item_stats[i]
			var stat_label = gui.item_stat_labels[i]
			if gui.item_data[item_id][stat_name] != null:
				var stat_value = gui.item_data[item_id][stat_name]
				get_node("Background/Margin/VBox/Stat" + str(item_stat) + "/Stat").set_text(stat_label)
				get_node("Background/Margin/VBox/Stat" + str(item_stat) + "/Value").set_text(str(stat_value))
				
				if gui.item_data[item_id]["EquipmentSlot"] != null and origin != "Equipment":
					var stat_difference = CompareItems(item_id, stat_name, stat_value)
					get_node("Background/Margin/VBox/Stat" + str(item_stat) + "/Difference").set_text("[" + str(stat_difference) + "]")
					if stat_difference > 0:
						get_node("Background/Margin/VBox/Stat" + str(item_stat) + "/Difference").set("custom_colors/font_color", Color.greenyellow)
					elif stat_difference < 0:
						get_node("Background/Margin/VBox/Stat" + str(item_stat) + "/Difference").set("custom_colors/font_color", Color.red)
				
				item_stat +=1


func CompareItems(item_id, stat_name, stat_value):
	var stat_difference
	var equipment_slot = gui.item_data[item_id]["EquipmentSlot"]
	if gui.equipment_data[equipment_slot] != null:
		var item_id_current = gui.equipment_data[equipment_slot]
		var stat_value_current = gui.item_data[str(item_id_current)][stat_name]
		stat_difference = stat_value - stat_value_current
	else:
		stat_difference = stat_value
	return stat_difference
