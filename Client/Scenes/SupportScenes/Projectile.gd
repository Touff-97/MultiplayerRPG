extends RigidBody

onready var collision = $Collision

var projectile_speed : int = 600
var life_time : int = 3
var damage : int


func _ready() -> void:
	Server.FetchSkillDamage("Arrow", get_instance_id())
	apply_impulse(Vector3(), Vector3(projectile_speed, 0, 0))
	SelfDestruct()


func SetDamage(s_damage: int) -> void:
	damage = s_damage


func SelfDestruct() -> void:
	yield(get_tree().create_timer(life_time), "timeout")
	queue_free()


func _on_Projectile_body_entered(body: Node) -> void:
	collision.set_deferred("disabled", true)
	if body.is_in_group("Enemies"):
		body.OnHit(damage)
	self.hide()
