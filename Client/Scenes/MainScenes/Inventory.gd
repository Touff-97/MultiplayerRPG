extends ScrollContainer

const template_inv_slot : PackedScene = preload("res://Scenes/SupportScenes/InventorySlot.tscn")

onready var gui = get_node("/root/SceneHandler/Map/GUI")
onready var gridcontainer = $InventorySlots

func _ready() -> void:
	for i in gui.inventory_data.keys():
		var new_inv_slot = template_inv_slot.instance()
		if gui.inventory_data[i]["Item"] != null:
			var item_name = gui.item_data[str(gui.inventory_data[i]["Item"])]["Name"]
			var icon_texture = load("res://Assets/Items/" + item_name + ".png")
			new_inv_slot.get_node("Icon").set_texture(icon_texture)
			var item_stack = gui.inventory_data[i]["Stack"]
			if item_stack != null and item_stack > 1:
				new_inv_slot.get_node("Stack").set_text(str(item_stack))
		gridcontainer.add_child(new_inv_slot, true)
