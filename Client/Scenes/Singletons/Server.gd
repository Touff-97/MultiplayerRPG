extends Node

# Network setup
var network = NetworkedMultiplayerENet.new()
var ip : String = "127.0.0.1"
var port : int = 1909
# Token verification on login
var token : String
# Clock syncronization
var client_clock : int = 0
var decimal_collector : float = 0.0
var latency_array : Array = []
var latency : int = 0
var delta_latency : int = 0


func _physics_process(delta: float) -> void:
	client_clock += int(delta * 1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00


func ConnectToServer() -> void:
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")


func _OnConnectionFailed() -> void:
	print("Failed to connect")


func _OnConnectionSucceeded() -> void:
	print("Succesfully connected to " + str(ip) + ":" + str(port))
	rpc_id(1, "FetchServerTime", OS.get_system_time_msecs())
	var timer : Timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
# warning-ignore:return_value_discarded
	timer.connect("timeout", self, "DetermineLatency")
	self.add_child(timer)


remote func ReturnServerTime(server_time, client_time) -> void:
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency


func DetermineLatency() -> void:
	rpc_id(1, "DetermineLatency", OS.get_system_time_msecs())


remote func ReturnLatency(client_time: int) -> void:
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size() - 1, - 1, - 1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size() - latency)
		latency = total_latency / latency_array.size()
		latency_array.clear()


remote func FetchToken() -> void:
	rpc_id(1, "ReturnToken", token)


remote func ReturnTokenVerificationResults(result: bool) -> void:
	if result:
		get_node("../SceneHandler/Map/GUI/LoginScreen").queue_free()
		get_node("../SceneHandler/Map/Objects/Player").set_physics_process(true)
		get_node("../SceneHandler/Map/GUI/ActionBar").set_physics_process(true)
		get_node("../SceneHandler/Map/GUI/ActionBar").visible = true
		print("Succesful token verification")
	else:
		print("Login failed, please try again")
		get_node("../SceneHandler/Map/GUI/LoginScreen").login_button.disabled = false
		get_node("../SceneHandler/Map/GUI/LoginScreen").create_account_button.disabled = false


func SendPlayerState(player_state: Dictionary) -> void:
	rpc_unreliable_id(1, "ReceivePlayerState", player_state)


remote func ReceiveWorldState(world_state: Dictionary) -> void:
	get_node("../SceneHandler/Map").UpdateWorldState(world_state)


remote func SpawnNewPlayer(player_id, spawn_position: Vector3) -> void:
	get_node("../SceneHandler/Map").SpawnNewPlayer(player_id, spawn_position)


remote func DespawnPlayer(player_id) -> void:
	get_node("../SceneHandler/Map").DespawnPlayer(player_id)


func FetchPlayerSkillTree() -> void:
	print("Fetching skill tree from server")
	rpc_id(1, "FetchPlayerSkillTree")


remote func ReturnPlayerSkillTree(player_skill_tree: Dictionary) -> void:
	print("Returning fetched skill tree")
	get_node("/root/SceneHandler/Map/GUI/SkillTree").LoadPlayerSkillTree(player_skill_tree)


func FetchSkillDamage(skill_name: String, requester) -> void:
	rpc_id(1, "FetchSkillDamage", skill_name, requester)


remote func ReturnSkillDamage(s_damage: int, requester) -> void:
	instance_from_id(requester).SetDamage(s_damage)


func FetchPlayerStats() -> void:
	rpc_id(1, "FetchPlayerStats")


remote func ReturnPlayerStats(stats) -> void:
	get_node("/root/SceneHandler/Map/GUI/PlayerStats").LoadPlayerStats(stats)
	get_node("/root/SceneHandler/Map/GUI/ActionBar").LoadPlayerStats(stats)


func SetStat(stat: String, new_value: int) -> void:
	print("Sending stat to server")
	rpc_id(1, "SetStat", stat, new_value)
