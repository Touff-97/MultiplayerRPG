extends Control

# UI state nodes
onready var login_screen : VBoxContainer = $Background/Margin/Login
onready var create_account_screen : VBoxContainer = $Background/Margin/CreateAccount
# Login nodes
onready var username_input : LineEdit = $Background/Margin/Login/Username
onready var userpassword_input : LineEdit = $Background/Margin/Login/Password
onready var login_button : Button = $Background/Margin/Login/LoginButton
onready var create_account_button : Button = $Background/Margin/Login/CreateAccountButton
# Create account nodes
onready var create_username_input : LineEdit = $Background/Margin/CreateAccount/Email
onready var create_password_input : LineEdit = $Background/Margin/CreateAccount/Password
onready var create_password_repeat_input : LineEdit = $Background/Margin/CreateAccount/RepeatPassword
onready var create_button : Button = $Background/Margin/CreateAccount/CreateButton
onready var back_button : Button = $Background/Margin/CreateAccount/BackButton


func _ready() -> void:
	username_input.grab_focus()


func _on_LoginButton_pressed() -> void:
	if username_input.text == "" or userpassword_input.text == "":
		print("Please provide a valid username and password")
	else:
		login_button.disabled = true
		create_account_button.disabled = true
		var username = username_input.get_text()
		var password = userpassword_input.get_text()
		print("attempting to login")
		Gateway.ConnectToServer(username, password, false)


func _on_CreateAccountButton_pressed() -> void:
	create_username_input.grab_focus()
	login_screen.hide()
	create_account_screen.show()


func _on_BackButton_pressed() -> void:
	username_input.grab_focus()
	login_screen.show()
	create_account_screen.hide()
	create_button.disabled = false
	back_button.disabled = false


func _on_CreateButton_pressed() -> void:
	if create_username_input.get_text() == "":
		print("Please provide a valid username")
	elif create_password_input.get_text() == "":
		print("Please provide a valid password")
	elif create_password_repeat_input.get_text() == "":
		print("Please repeat your password")
	elif create_password_input.get_text() != create_password_repeat_input.get_text():
		print("Passwords don't match")
	elif create_password_input.get_text().length() <= 7:
		print("Password must contain at least 8 characters")
	else:
		create_button.disabled = true
		back_button.disabled = true
		var username : String = create_username_input.get_text()
		var password : String = create_password_input.get_text()
		Gateway.ConnectToServer(username, password, true)
