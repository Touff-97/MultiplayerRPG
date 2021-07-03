extends Control

onready var class_race = $Background/Margin/VBox/ClassRaceLevel/RaceClass
onready var level = $Background/Margin/VBox/ClassRaceLevel/StatValue
onready var reputation = $Background/Margin/VBox/Player/Reputation/StatValue
onready var stat_points = $Background/Margin/VBox/Player/StatPoints/StatValue
onready var health = $Background/Margin/VBox/Stats/Health/Values/StatValue
onready var strength = $Background/Margin/VBox/Stats/Strength/Values/StatValue
onready var defense = $Background/Margin/VBox/Stats/Defense/Values/StatValue
onready var speed = $Background/Margin/VBox/Stats/Speed/Values/StatValue
onready var stamina = $Background/Margin/VBox/Stats/Stamina/Values/StatValue
onready var endurance = $Background/Margin/VBox/Stats/Endurance/Values/StatValue
onready var dexterity = $Background/Margin/VBox/Stats/Dexterity/Values/StatValue
onready var accuracy = $Background/Margin/VBox/Stats/Accuracy/Values/StatValue
onready var luck = $Background/Margin/VBox/Stats/Luck/Values/StatValue


func _ready() -> void:
	visible = false


func _physics_process(_delta: float) -> void:
	for plus in get_tree().get_nodes_in_group("plus"):
		if int(stat_points.get_text()) == 0:
			plus.disabled = true
		else:
			plus.disabled = false
		
	
	for minus in get_tree().get_nodes_in_group("minus"):
		if int(minus.parent.get_node("Values/StatValue").get_text()) == 0:
			minus.disabled = true
		else:
			minus.disabled = false


func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("stats"):
		Server.FetchPlayerStats()
		visible = !visible


func LoadPlayerStats(stats: Dictionary) -> void:
	class_race.set_text(stats.Class + " " + stats.Race)
	level.set_text(str(stats.Level))
	reputation.set_text(str(stats.Reputation))
	stat_points.set_text(str(stats.StatPoints))
	health.set_text(str(stats.Health))
	strength.set_text(str(stats.Strength))
	defense.set_text(str(stats.Defense))
	speed.set_text(str(stats.Speed))
	stamina.set_text(str(stats.Stamina))
	endurance.set_text(str(stats.Endurance))
	dexterity.set_text(str(stats.Dexterity))
	accuracy.set_text(str(stats.Accuracy))
	luck.set_text(str(stats.Luck))


func IncreaseStat(stat: String) -> void:
	print("Plus pressed")
	# If there're no stat points return
	if int(stat_points.get_text()) <= 0:
		print("You've got no more points to spend")
		return
	# Set a new value for the desired stat and decrease the stat points
	var new_value = int(get_node("Background/Margin/VBox/Stats/" + stat + "/Values/StatValue").get_text()) + 1
	var new_stat_points = int(get_node("Background/Margin/VBox/Player/StatPoints/StatValue").get_text()) - 1
	# Set the values on the server side
	ModifyStat(stat, new_value)
	ModifyStat("StatPoints", new_stat_points)


func DecreaseStat(stat: String) -> void:
	print("Minus pressed")
	# If the stat's empty return
	if int(get_node("Background/Margin/VBox/Stats/" + stat + "/Values/StatValue").get_text()) <= 0:
		print("You've got no more points to remove")
		return
	# Set a new value for the desired stat and increase the stat points
	var new_value = int(get_node("Background/Margin/VBox/Stats/" + stat + "/Values/StatValue").get_text()) - 1
	var new_stat_points = int(get_node("Background/Margin/VBox/Player/StatPoints/StatValue").get_text()) + 1
	# Set the values on the server side
	ModifyStat(stat, new_value)
	ModifyStat("StatPoints", new_stat_points)


func ModifyStat(stat: String, new_value: int) -> void:
	Server.SetStat(stat, new_value)
	Server.FetchPlayerStats()
