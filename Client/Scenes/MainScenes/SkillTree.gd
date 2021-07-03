extends Control

const skillTemplate = preload("res://Scenes/SupportScenes/Skill.tscn")

onready var utility = $Background/Margin/VBox/Utility
onready var utility_button = $Background/Margin/VBox/TabButtons/UtilitySkills
onready var combat = $Background/Margin/VBox/Combat
onready var combat_button = $Background/Margin/VBox/TabButtons/CombatSkills
onready var magic = $Background/Margin/VBox/Magic
onready var magic_button = $Background/Margin/VBox/TabButtons/MagicSkills


func _ready() -> void:
	visible = false


func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("skill_tree"):
		print("Fetching skill tree")
		Server.FetchPlayerSkillTree()
		visible = !visible


func _on_UtilitySkills_pressed() -> void:
	utility.show()
	utility_button.pressed = true
	combat.hide()
	combat_button.pressed = false
	magic.hide()
	magic_button.pressed = false


func _on_CombatSkills_pressed() -> void:
	utility.hide()
	utility_button.pressed = false
	combat.show()
	combat_button.pressed = true
	magic.hide()
	magic_button.pressed = false


func _on_MagicSkills_pressed() -> void:
	utility.hide()
	utility_button.pressed = false
	combat.hide()
	combat_button.pressed = false
	magic.show()
	magic_button.pressed = true


func LoadPlayerSkillTree(player_skill_tree: Dictionary) -> void:
	print("Player skill tree loaded")
	for tab in player_skill_tree.keys():
		for skill in player_skill_tree[tab].keys():
			if get_node("Background/Margin/VBox/" + tab).get_child_count() <= 8:
				var new_skill = skillTemplate.instance()
				new_skill.name = player_skill_tree[tab][skill].Name
				new_skill.get_node("Values/HBox/Skill").set_text(player_skill_tree[tab][skill].Name)
				new_skill.get_node("Values/HBox/Stage").set_text(player_skill_tree[tab][skill].Stage + " " + player_skill_tree[tab][skill].Level)
				get_node("Background/Margin/VBox/" + tab).add_child(new_skill, true)
			else:
				pass
				
