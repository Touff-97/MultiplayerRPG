extends Node

var skill_tree_data : Dictionary
var skill_tree_path : String = "res://Data/SkillTreeData.json"

var skill_data : Dictionary
var skill_path : String = "res://Data/SkillData.json"

var stat_data : Dictionary
var stat_path : String = "res://Data/StatData.json"

var item_data : Dictionary
var item_path : String = "res://Data/ItemData.json"

var equipment_data : Dictionary
var equipment_path : String = "res://Data/EquipmentData.json"

var inventory_data : Dictionary
var inventory_path : String = "res://Data/InventoryData.json"

var hotbar_data : Dictionary
var hotbar_path : String = "res://Data/HotbarData.json"


func _ready() -> void:
	RetreiveSkillTreeData()
	RetreiveSkillData()
	RetreiveStatData()
	RetreiveItemData()
	RetreiveEquipmentData()
	RetreiveInventoryData()
	RetreiveHotbarData()


func RetreiveSkillTreeData() -> void:
	var skill_tree_data_file = File.new()
	skill_tree_data_file.open(skill_tree_path, File.READ)
	var skill_tree_data_json = JSON.parse(skill_tree_data_file.get_as_text())
	skill_tree_data_file.close()
	skill_tree_data = skill_tree_data_json.result


func RetreiveSkillData() -> void:
	var skill_data_file = File.new()
	skill_data_file.open(skill_path, File.READ)
	var skill_data_json = JSON.parse(skill_data_file.get_as_text())
	skill_data_file.close()
	skill_data = skill_data_json.result


func RetreiveStatData() -> void:
	var stat_data_file = File.new()
	stat_data_file.open(stat_path, File.READ)
	var stat_data_json = JSON.parse(stat_data_file.get_as_text())
	stat_data_file.close()
	stat_data = stat_data_json.result


func RetreiveItemData() -> void:
	var item_data_file = File.new()
	item_data_file.open(item_path, File.READ)
	var item_data_json = JSON.parse(item_data_file.get_as_text())
	item_data_file.close()
	item_data = item_data_json.result


func RetreiveEquipmentData() -> void:
	var equip_data_file = File.new()
	equip_data_file.open(equipment_path, File.READ)
	var equip_data_json = JSON.parse(equip_data_file.get_as_text())
	equip_data_file.close()
	equipment_data = equip_data_json.result


func RetreiveInventoryData() -> void:
	var inv_data_file = File.new()
	inv_data_file.open(inventory_path, File.READ)
	var inv_data_json = JSON.parse(inv_data_file.get_as_text())
	inv_data_file.close()
	inventory_data = inv_data_json.result


func RetreiveHotbarData() -> void:
	var hotbar_data_file = File.new()
	hotbar_data_file.open(hotbar_path, File.READ)
	var hotbar_data_json = JSON.parse(hotbar_data_file.get_as_text())
	hotbar_data_file.close()
	hotbar_data = hotbar_data_json.result
