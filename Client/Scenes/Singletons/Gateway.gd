extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip : String = "127.0.0.1"
var port : int = 1910
var cert = load("res://Resources/Certificate/X509_Certificate.crt")

var username : String
var password : String
var new_account : bool


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func ConnectToServer(_username : String, _password : String, _new_account : bool) -> void:
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false) # Set to trie when using a signed certificate
	network.set_dtls_certificate(cert)
	username = _username
	password = _password
	new_account = _new_account
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")


func _OnConnectionFailed() -> void:
	print("Failed to connect to login server")
	print("Popup server offline")
	get_node("../SceneHandler/Map/GUI/LoginScreen").login_button.disabled = false
	get_node("../SceneHandler/Map/GUI/LoginScreen").create_account_button.disabled = false
	get_node("../SceneHandler/Map/GUI/LoginScreen").create_button.disabled = false
	get_node("../SceneHandler/Map/GUI/LoginScreen").back_button.disabled = false


func _OnConnectionSucceeded() -> void:
	print("Succesfully connected to login server")
	if new_account:
		RequestCreateAccount()
	else:
		RequestLogin()


func RequestLogin() -> void:
	print("Connecting to gateway to request login")
	rpc_id(1, "LoginRequest", username, password)
	username = ""
	password = ""


remote func ReturnLoginRequest(results: bool, token: String) -> void:
	print("results received")
	
	if results:
		Server.token = token
		Server.ConnectToServer()
	else:
		print("Please provide correct username and password")
		get_node("../SceneHandler/Map/GUI/LoginScreen").login_button.disabled = false
		get_node("../SceneHandler/Map/GUI/LoginScreen"). create_account_button.disabled = false
	
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")


func RequestCreateAccount() -> void:
	print("Requesting new account")
	rpc_id(1, "CreateAccountRequest", username, password)
	username = ""
	password = ""


remote func ReturnCreateAccountRequest(results: bool, message: int) -> void:
	print("results received")
	if results:
		print("Account created, please proceed with logging in")
		get_node("../SceneHandler/Map/GUI/LoginScreen")._on_BackButton_pressed()
	else:
		if message == 1:
			print("Couldn't create account, please try again")
		elif message == 2:
			print("The username already exists, please use a different one")
		get_node("../SceneHandler/Map/GUI/LoginScreen").create_button.disabled = false
		get_node("../SceneHandler/Map/GUI/LoginScreen").back_button.disabled = false
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
