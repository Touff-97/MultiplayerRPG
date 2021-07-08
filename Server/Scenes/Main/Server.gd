extends Node

var network = NetworkedMultiplayerENet.new()
var port : int = 1909
var max_players : int = 100

var expected_tokens : Array = []
var player_state_collection : Dictionary = {}

onready var player_verification_process = $PlayerVerification
onready var combat_functions = $Combat


func _ready() -> void:
	StartServer()


func StartServer() -> void:
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "_Peer_Conected")
	network.connect("peer_disconnected", self, "_Peer_Disconected")


func _Peer_Conected(player_id) -> void:
	print("User " + str(player_id) + " Connected")
	player_verification_process.start(player_id)


func _Peer_Disconected(player_id) -> void:
	print("User " + str(player_id) + " Disconnected")
	if has_node(str(player_id)):
		get_node(str(player_id)).queue_free()
# warning-ignore:return_value_discarded
		player_state_collection.erase(player_id)
		rpc_id(0, "DespawnPlayer", player_id)


func _on_TokenExpiration_timeout() -> void:
	var current_time = OS.get_unix_time()
	var token_time
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() -1, -1, -1):
			token_time = int(expected_tokens[i].right(64))
			if current_time - token_time >= 30:
				expected_tokens.remove(i)


remote func FetchServerTime(client_time: int) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnServerTime", OS.get_system_time_msecs(), client_time)


remote func DetermineLatency(client_time: int) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnLatency", client_time)


func FetchToken(player_id) -> void:
	rpc_id(player_id, "FetchToken")


remote func ReturnToken(token) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.Verify(player_id, token)


func ReturnTokenVerificationResults(player_id, result) -> void:
	rpc_id(player_id, "ReturnTokenVerificationResults", result)
	if result:
		rpc_id(0, "SpawnNewPlayer", player_id, Vector3(5, 2, 5))


remote func ReceivePlayerState(player_state: Dictionary) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["T"] < player_state["T"]:
			player_state_collection[player_id] = player_state
	else:
		player_state_collection[player_id] = player_state


func SendWorldState(world_state: Dictionary) -> void:
	rpc_unreliable_id(0, "ReceiveWorldState", world_state)


remote func FetchPlayerSkillTree() -> void:
	var player_id = get_tree().get_rpc_sender_id()
	var player_skill_tree = get_node(str(player_id)).player_skill_tree
	rpc_id(player_id, "ReturnPlayerSkillTree", player_skill_tree)


remote func FetchSkillDamage(skill_name, requester) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	var damage = combat_functions.FetchSkillDamage(skill_name, player_id)
	rpc_id(player_id, "ReturnSkillDamage", damage, requester)


remote func FetchPlayerStats() -> void:
	var player_id = get_tree().get_rpc_sender_id()
	var player_stats = get_node(str(player_id)).player_stats
	rpc_id(player_id, "ReturnPlayerStats", player_stats)


remote func SetStat(stat, new_value) -> void:
	var player_id = get_tree().get_rpc_sender_id()
	get_node(str(player_id)).player_stats[stat] = new_value


remote func FetchInventoryData() -> void:
	var player_id = get_tree().get_rpc_sender_id()
	var equipment = get_node(str(player_id)).player_equipment
	var inventory = get_node(str(player_id)).player_inventory
	var hotbar = get_node(str(player_id)).player_hotbar
	var item_data = ServerData.item_data
	rpc_id(player_id, "ReturnInventoryData", equipment, inventory, hotbar, item_data)
