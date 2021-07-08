extends Popup

var data : Dictionary


func _ready() -> void:
	get_node("Background/Margin/HBox/Amount").grab_focus()


func _on_Confirm_pressed() -> void:
	var split_amount = get_node("Background/Margin/HBox/Amount").get_text()
	if split_amount == "":
		split_amount = 1
	if int(split_amount) >= data["origin_stack"]:
		split_amount = data["origin_stack"] - 1
	get_parent().SplitStack(int(split_amount), data)
	self.queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_Confirm_pressed()
