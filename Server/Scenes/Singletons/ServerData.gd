extends Node

var skill_tree_data : Dictionary
var skill_tree_path : String = "res://Data/SkillTreeData.json"

var skill_data : Dictionary
var skill_path : String = "res://Data/SkillData.json"

var stat_data : Dictionary
var stat_path : String = "res://Data/StatData.json"


func _ready() -> void:
	RetrieveSkillTreeData()
	RetreiveSkillData()
	RetreiveStatData()


func RetrieveSkillTreeData() -> void:
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
