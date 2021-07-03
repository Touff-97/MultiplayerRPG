extends Node

var world_state : Dictionary = {}


func _physics_process(_delta: float) -> void:
	if not get_parent().player_state_collection.empty():
		world_state = get_parent().player_state_collection.duplicate(true)
		for player in world_state.keys():
			world_state[player].erase("T")
		world_state["T"] = OS.get_system_time_msecs()
		# Verifications
		# Anti-Cheat
		# Chunks or maps
		# Physics checks
		# Etcetera
		get_parent().SendWorldState(world_state)
