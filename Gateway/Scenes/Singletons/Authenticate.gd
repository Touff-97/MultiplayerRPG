extends Node

var network = NetworkedMultiplayerENet.new()
var ip : String = "127.0.0.1"
var port : int = 1911


func _ready() -> void:
	ConnectToServer()


func ConnectToServer() -> void:
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")


func _OnConnectionFailed() -> void:
	print("Failed to connect")


func _OnConnectionSucceeded() -> void:
	print("Succesfully connected to authentication server")


func AuthenticatePlayer(username: String, password: String, player_id) -> void:
	print("sending out authentication request")
	rpc_id(1, "AuthenticatePlayer", username, password, player_id)


remote func AuthenticationResults(result: bool, player_id, token) -> void:
	print("results received and replying to player login request")
	Gateway.ReturnLoginRequest(result, player_id, token)


func CreateAccount(username : String, password : String, player_id) -> void:
	print("sending out create account request")
	rpc_id(1, "CreateAccount", username, password, player_id)


remote func CreateAccountResults(result : bool, player_id, message : int) -> void:
	print("results received and replying to player create account request")
	Gateway.ReturnCreateAccountRequest(result, player_id, message)
