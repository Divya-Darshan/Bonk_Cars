extends RigidBody2D

var wheels := []

@export var speed := 60000.0
@export var air_torque := 12000.0
@export var stabilize_strength := 8.0
@export var flip_force := 25000.0

func _ready():
	wheels = get_tree().get_nodes_in_group("wheel")


func _physics_process(delta):
	var dir := Input.get_axis("ui_left", "ui_right")

	# === WHEEL DRIVE ===
	if abs(dir) > 0.01:
		for wheel in wheels:
			wheel.apply_torque_impulse(dir * speed * delta)

	# === AIR CONTROL (makes it feel fun) ===
	if not is_on_floor_fake():
		apply_torque(dir * air_torque * delta)

	# === AUTO BALANCE (wobbly but controllable) ===
	var target_angle := 0.0
	var angle_diff := wrapf(rotation - target_angle, -PI, PI)
	apply_torque(-angle_diff * stabilize_strength)

	# === FLIP CAR (press SPACE / ui_accept) ===
	if Input.is_action_just_pressed("ui_accept"):
		flip_car()


# --- FAKE GROUND CHECK ---
func is_on_floor_fake() -> bool:
	for wheel in wheels:
		if wheel.get_contact_count() > 0:
			return true
	return false


# --- FLIP FUNCTION ---
func flip_car():
	# reset rotation upright
	rotation = 0

	# small upward push so it doesn’t stick
	apply_impulse(Vector2(0, -flip_force * 0.1))

	# stop spin
	angular_velocity = 0
