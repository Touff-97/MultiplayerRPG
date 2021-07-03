extends KinematicBody

onready var body = $Body
onready var collision = $Collision
onready var hitbox = $HitBox

var max_hp : int = 400
var current_hp : int

func _ready() -> void:
	current_hp = max_hp


func OnHit(damage : int) -> void:
	current_hp -= damage
	if current_hp <= 0:
		OnDeath()


func OnDeath() -> void:
	body.rotation_degrees.x = 0
	collision.set_deferred("disabled", true)
	hitbox.set_deferred("disabled", true)
