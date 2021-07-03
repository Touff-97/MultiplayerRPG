extends Button

onready var parent = get_parent().get_parent()


func _on_Plus_pressed() -> void:
	get_node("../../../../../../../").IncreaseStat(parent.get_name())
