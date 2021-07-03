extends Button

onready var parent = get_parent().get_parent()


func _on_Minus_pressed() -> void:
	print(get_node("../../../../../../../").get_name())
	get_node("../../../../../../../").DecreaseStat(parent.get_name())
