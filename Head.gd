extends Node3D

const SENSITIVITY = 3

# Head bob variables.
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

# FOV variables.
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

@onready var character = $".."
@onready var camera = $Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		character.rotate_y(-event.relative.x * SENSITIVITY / 1000)
		camera.rotate_x(-event.relative.y * SENSITIVITY / 1000)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta):
	# Head bob
	t_bob += delta * character.velocity.length() * float(character.is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(character.velocity.length(), 0.5, character.SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
