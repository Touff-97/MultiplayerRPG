extends CanvasLayer

const stat_menu : PackedScene = preload("res://Scenes/MainScenes/PlayerStats.tscn")
const skill_menu : PackedScene = preload("res://Scenes/MainScenes/SkillTree.tscn")
const inventory_menu : PackedScene = preload("res://Scenes/MainScenes/Inventory.tscn")

export(Dictionary) var equipment_data = {}
export(Dictionary) var inventory_data = {}
export(Dictionary) var hotbar_data = {}
export(Dictionary) var item_data = {}

var item_stats : Array = ["Attack", "Defense", "Block", "PotionHealth", "PotionMana", "FoodSatiation"]
var item_stat_labels : Array = ["Attack", "Defense", "Block", "Health", "Mana", "Satiation"]


func _unhandled_input(event: InputEvent) -> void:
	# Menus
	if event.is_action_pressed("skill_tree"):
		if not has_node("SkillTree"):
			InstanceMenu(skill_menu)
		else:
			get_node("SkillTree").visible = !get_node("SkillTree").visible
		Server.FetchPlayerSkillTree()
	
	if event.is_action_pressed("stats"): # Player Stats
		if not has_node("PlayerStats"):
			InstanceMenu(stat_menu)
		else:
			get_node("PlayerStats").visible = !get_node("PlayerStats").visible
		Server.FetchPlayerStats()
	
	if event.is_action_pressed("inventory"):
		Server.FetchInventoryData()
		if not has_node("Inventory"):
			InstanceMenu(inventory_menu)
		else:
			get_node("Inventory/Background").visible = !get_node("Inventory/Background").visible


func InstanceMenu(menu: PackedScene) -> void:
	var new_menu = menu.instance() 
	add_child(new_menu, true)


func LoadPlayerSkillTree(player_skill_tree: Dictionary) -> void:
	if get_node("SkillTree"):
		get_node("SkillTree").LoadPlayerSkillTree(player_skill_tree)


func LoadPlayerStats(stats: Dictionary) -> void:
	if get_node("PlayerStats"):
		get_node("PlayerStats").LoadPlayerStats(stats)


func LoadInventoryData(_equipment_data: Dictionary, _inventory_data: Dictionary, _hotbar_data: Dictionary, _item_data: Dictionary) -> void:
	equipment_data = _equipment_data
	inventory_data = _inventory_data
	hotbar_data = _hotbar_data
	item_data = _item_data
