extends KinematicBody

const projectile : PackedScene = preload("res://Scenes/SupportScenes/Projectile.tscn")

# State machine
enum States {
	MOVING,
	ATTACKING,
}

var state = States.MOVING

# Movement
export(int) var max_speed = 10
export(int) var acceleration = 70
export(int) var friction = 60
export(int) var air_friction = 10
export(int) var gravity = -40
export(int) var jump_impulse = 20
export(float) var mouse_sensitivity = 0.1
export(int) var controller_sensitivity = 3
export(int) var rot_speed = 30

var velocity : Vector3 = Vector3.ZERO
var snap_vector : Vector3 = Vector3.ZERO

onready var spring_arm = $SpringArm
onready var pivot = $Pivot

# Multiplayer variables
var player_state : Dictionary = {}


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Multiplayer needed
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	StateMachine(delta)
	# Multiplayer function
	DefinePlayerState()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_mouse_captured"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		spring_arm.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))


func StateMachine(delta: float) -> void:
	match state:
		States.MOVING:
			MovingLoop(delta)
		States.ATTACKING:
			AttackingLoop()
		_:
			pass


func MovingLoop(delta: float) -> void:
	var input_vector = get_input_vector()
	var direction = get_direction(input_vector)
	
	apply_movement(input_vector, direction, delta)
	apply_friction(direction, delta)
	apply_gravity(delta)
	update_snap_vector()
	jump()
	apply_controller_rotation()
	
	spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg2rad(-75), deg2rad(75))
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)
	
	if Input.is_action_pressed("attack"):
		state = States.ATTACKING


func get_input_vector() -> Vector3:
	var input_vector = Vector3.ZERO
	
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	
	return input_vector.normalized() if input_vector.length() > 1 else input_vector


func get_direction(input_vector: Vector3):
	var direction = (input_vector.x * transform.basis.x) + (input_vector.z * transform.basis.z)
	return direction


func apply_movement(input_vector: Vector3, direction: Vector3, delta: float) -> void:
	if direction != Vector3.ZERO:
		velocity.x = velocity.move_toward(direction * max_speed, acceleration * delta).x
		velocity.z = velocity.move_toward(direction * max_speed, acceleration * delta).z
		pivot.rotation.y = lerp_angle(pivot.rotation.y, atan2(-input_vector.x, -input_vector.z), rot_speed * delta)


func apply_friction(direction: Vector3, delta: float) -> void:
	if direction == Vector3.ZERO:
		if is_on_floor():
			velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		else:
			velocity.x = velocity.move_toward(direction * max_speed, air_friction * delta).x
	
	velocity.z = velocity.move_toward(direction * max_speed, air_friction * delta).z



func apply_gravity(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.y = clamp(velocity.y, gravity, jump_impulse)


func update_snap_vector() -> void:
	snap_vector = -get_floor_normal() if is_on_floor() else Vector3.DOWN


func apply_controller_rotation() -> void:
	var axis_vector : Vector2 = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if InputEventJoypadMotion:
		rotate_y(deg2rad(-axis_vector.x) * controller_sensitivity)
		spring_arm.rotate_x(deg2rad(-axis_vector.y) * controller_sensitivity)


func AttackingLoop() -> void:
	var projectile_instance = projectile.instance()
	projectile_instance.translation = translation
	get_parent().add_child(projectile_instance)

	state = States.MOVING


func jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap_vector = Vector3.ZERO
		velocity.y = jump_impulse
	if Input.is_action_just_released("jump") and velocity.y > jump_impulse / 2:
		velocity.y = jump_impulse / 2


func DefinePlayerState() -> void:
	player_state = {"T": OS.get_system_time_msecs(), "P": translation}
	Server.SendPlayerState(player_state)
