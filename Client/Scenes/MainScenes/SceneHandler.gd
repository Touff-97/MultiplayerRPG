extends Node

var mapstart : PackedScene = preload("res://Scenes/MainScenes/Map.tscn")


func _ready() -> void:
	var mapstart_instance = mapstart.instance()
	add_child(mapstart_instance)
