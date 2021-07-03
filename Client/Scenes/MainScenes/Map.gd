extends Spatial

const interpolation_offset : int = 100

var player_spawn = preload("res://Scenes/MainScenes/PlayerTemplate.tscn")
var last_world_state : int = 0

var world_state_buffer : Array = []


func SpawnNewPlayer(player_id, spawn_position: Vector3) -> void:
	if get_tree().get_network_unique_id() == player_id:
		pass
	else:
		if not get_node("Objects/OtherPlayers").has_node(str(player_id)):
			var new_player = player_spawn.instance()
			new_player.translation = spawn_position
			new_player.name = str(player_id)
			get_node("Objects/OtherPlayers").add_child(new_player)


func DespawnPlayer(player_id) -> void:
	yield(get_tree().create_timer(0.2), "timeout")
	get_node("Objects/OtherPlayers/" + str(player_id)).queue_free()


func UpdateWorldState(world_state: Dictionary) -> void:
	# Buffer: Array of past, present and future positions based on a 100ms offset
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)


func _physics_process(_delta: float) -> void:
	var render_time = OS.get_system_time_msecs() - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
		if world_state_buffer.size() > 2:
			# Interpolation: Lerping function between present and future player positions
			var interpolation_factor : float = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[2].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[1].has(player):
					continue
				if get_node("Objects/OtherPlayers").has_node(str(player)):
					var new_position : Vector3 = lerp(world_state_buffer[1][player]["P"], world_state_buffer[2][player]["P"], interpolation_factor)
					get_node("Objects/OtherPlayers/" + str(player)).MovePlayer(new_position)
				else:
					print("spawning player")
					SpawnNewPlayer(player, world_state_buffer[2][player]["P"])
		elif render_time > world_state_buffer[1].T:
			# Extrapolation: Aproximation of a future position based on past and present positions
			var extrapolation_factor : float = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.00
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[0].has(player):
					continue
				if get_node("Objects/OtherPlayers").has_node(str(player)):
					var position_delta : Vector3 = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
					var new_position : Vector3 = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
					get_node("Objects/OtherPlayers/" + str(player)).MovePlayer(new_position)


func UpdateWorldStateOLD(world_state: Dictionary) -> void:
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state.erase("T")
		world_state.erase(get_tree().get_network_unique_id())
		for player in world_state.keys():
			if get_node("Objects/OtherPlayers").has_node(str(player)):
				get_node("Objects/OtherPlayers/" + str(player)).MovePlayer(world_state[player]["P"])
			else:
				SpawnNewPlayer(player, world_state[player]["P"])



