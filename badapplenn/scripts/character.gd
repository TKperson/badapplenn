extends CharacterBody3D

@onready var head = $head

const SPEED = 5.0
const SPRING_SPEED = 10.0
const FLY_VELOCITY = 4.5

const MOUSE_SENSITIVITY = 0.003

var lerp_speed = 10.0;
var direction = Vector3.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, -PI / 2, PI / 2)

func _physics_process(delta):
	if Input.is_action_pressed("up"):
		velocity.y = lerp(velocity.y, FLY_VELOCITY, delta * lerp_speed)
	elif not is_on_floor() and Input.is_action_pressed("down"):
		velocity.y = lerp(velocity.y, -FLY_VELOCITY, delta * lerp_speed)
	else:
		velocity.y = lerp(velocity.y, 0.0, delta * lerp_speed)

	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	
	var movement_speed = SPEED
	if Input.is_action_pressed("sprint"):
		movement_speed = SPRING_SPEED
	
	if direction:
		velocity.x = direction.x * movement_speed
		velocity.z = direction.z * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		velocity.z = move_toward(velocity.z, 0, movement_speed)

	move_and_slide()
