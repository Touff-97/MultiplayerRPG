extends Control

onready var action_bar = $Margin/VBox/ActionBar
onready var experience = $Margin/VBox/ExperienceBar
onready var skill = $Margin/VBox/SkillBar
onready var hearts = $Margin/VBox/Hearts


func _ready() -> void:
	set_physics_process(false)
	visible = false


func _physics_process(_delta: float) -> void:
	var timer : int = 0
	while timer < 5:
		timer += 1
		break
	Server.FetchPlayerStats()
	timer = 0


func LoadPlayerStats(stats: Dictionary) -> void:
	# Basic information display (Class, level, and selected skill)
	action_bar.set_text("<< " + stats.Class + " · Level " + str(stats.Level) + " · Swordsmanship >>")
	
	# Hearts display using Health stat
	var heart_icon_x : int = 29
	if stats.Health < 18:
		hearts.rect_size.x = (heart_icon_x * 2) + (((heart_icon_x / 2) * stats.Health) + 1)
		hearts.rect_position.x = 411 - ((heart_icon_x / 4) * stats.Health)
	else:
		hearts.rect_size.x = heart_icon_x * 10
		hearts.rect_position.x = 292
