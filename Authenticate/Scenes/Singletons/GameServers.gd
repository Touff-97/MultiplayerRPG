extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port : int = 1912
var max_players : int = 100

var gameserverlist : Dictionary = {}


func _ready() -> void:
	StartServer()


func _process(_delta: float) -> void:
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func StartServer() -> void:
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("GameServerHub started")
	
	network.connect("peer_connected", self, "_Peer_Conected")
	network.connect("peer_disconnected", self, "_Peer_Disconected")


func _Peer_Conected(gameserver_id) -> void:
	print("Game Server " + str(gameserver_id) + " Connected")
	gameserverlist["GameServer1"] = gameserver_id
	print(gameserverlist)


func _Peer_Disconected(gameserver_id) -> void:
	print("Game Server " + str(gameserver_id) + " Disonnected")


func DistributeLoginToken(token, gameserver) -> void:
	var gameserver_peer_id = gameserverlist[gameserver]
	rpc_id(gameserver_peer_id, "ReceiveLoginToken", token)
