extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port : int = 1910
var max_players : int = 100
var cert = load("res://Certificate/X509_Certificate.crt")
var key = load("res://Certificate/x509_key.key")


func _ready() -> void:
	StartServer()


func _process(_delta: float) -> void:
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func StartServer() -> void:
	network.set_dtls_enabled(true)
	network.set_dtls_key(key)
	network.set_dtls_certificate(cert)
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("Gateway Server started")
	
	network.connect("peer_connected", self, "_Peer_Conected")
	network.connect("peer_disconnected", self, "_Peer_Disconected")


func _Peer_Conected(player_id) -> void:
	print("User " + str(player_id) + " Connected")


func _Peer_Disconected(player_id) -> void:
	print("User " + str(player_id) + " Disconnected")


remote func LoginRequest(username: String, password: String) -> void:
	print("login request received")
	var player_id = custom_multiplayer.get_rpc_sender_id()
	Authenticate.AuthenticatePlayer(username, password.sha256_text(), player_id)


func ReturnLoginRequest(result: bool, player_id, token) -> void:
	rpc_id(player_id, "ReturnLoginRequest", result, token)
	network.disconnect_peer(player_id)


remote func CreateAccountRequest(username : String, password : String) -> void:
	var player_id = custom_multiplayer.get_rpc_sender_id()
	var valid_request = true
	if username == "":
		valid_request = false
	if password == "":
		valid_request = false
	if password.length() <= 7:
		valid_request = false
	
	if valid_request == false:
		ReturnCreateAccountRequest(valid_request, player_id, 1)
	else:
		Authenticate.CreateAccount(username.to_lower(), password.sha256_text(), player_id)


func ReturnCreateAccountRequest(result : bool, player_id, message: int) -> void:
	rpc_id(player_id, "ReturnCreateAccountRequest", result, message)
	# 1 = failed to create, 2 = existing username, 3 = welcome
	network.disconnect_peer(player_id)
