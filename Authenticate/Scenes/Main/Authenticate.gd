extends Node

var network = NetworkedMultiplayerENet.new()
var port : int = 1911
var max_servers = 5


func _ready() -> void:
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	print("Authentication Server started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")


func _Peer_Connected(gateway_id) -> void:
	print("Gateway " + str(gateway_id) + " Connected")


func _Peer_Disconnected(gateway_id) -> void:
	print("Gateway " + str(gateway_id) + " Disconnected")


remote func AuthenticatePlayer(username: String, password: String, player_id) -> void:
	var gateway_id = get_tree().get_rpc_sender_id()
	var hashed_password : String
	var token : String
	var result : bool
	
	if not PlayerData.PlayerIDs.has(username.to_lower()):
		result = false
	else:
		var retrieved_salt = PlayerData.PlayerIDs[username.to_lower()].Salt
		hashed_password = GenerateHashedPassword(password, retrieved_salt)
		
		if not PlayerData.PlayerIDs[username.to_lower()].Password == hashed_password:
			result = false
		else:
			result = true
		
			randomize()
			token = str(randi()).sha256_text() + str(OS.get_unix_time())
			var gameserver = "GameServer1"
			GameServers.DistributeLoginToken(token, gameserver)
	
	rpc_id(gateway_id, "AuthenticationResults", result, player_id, token)


remote func CreateAccount(username: String, password: String, player_id) -> void:
	var gateway_id = get_tree().get_rpc_sender_id()
	var result : bool
	var message : int
	if PlayerData.PlayerIDs.has(username):
		result = false
		message = 2
	else:
		result = true
		message = 3
		var salt = GenerateSalt()
		var hashed_password = GenerateHashedPassword(password, salt)
		PlayerData.PlayerIDs[username] = {"Password": hashed_password, "Salt": salt}
		PlayerData.SavePlayerIDs()
	
	rpc_id(gateway_id, "CreateAccountResults", result, player_id, message)


func GenerateSalt() -> String:
	randomize()
	var salt = str(randi()).sha256_text()
	print("Salt: " + salt)
	return salt


func GenerateHashedPassword(password: String, salt: String) -> String:
	var hashed_password = password
	var rounds = pow(2, 18)
	print("hashed password as input: " + hashed_password)
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	print("final hashed password: " + hashed_password)
	return hashed_password
	
