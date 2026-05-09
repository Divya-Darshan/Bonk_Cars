extends RigidBody2D

var wheels := []

@export var drive_force := 70000.0
@export var air_rotate_force := 90000.0
@export var air_float := 0.996
@export var tilt_force := 2500.0
@export var flip_force := 25000.0

func _ready():
	wheels = get_tree().get_nodes_in_group("wheel")


func _physics_process(delta):

	var dir := Input.get_axis("ui_left", "ui_right")

	# =========================
	# DRIVE
	# =========================
	if abs(dir) > 0.01:

		for wheel in wheels:
			wheel.apply_torque_impulse(dir * drive_force * delta)

		# makes car lean while driving
		apply_torque(dir * tilt_force * delta)

	# =========================
	# AIR CONTROL
	# =========================
	if not is_grounded():

		# Drive Ahead style opposite spin
		apply_torque_impulse(-dir * air_rotate_force * delta)

		# slightly floaty
		linear_velocity.y *= air_float

	# =========================
	# RESET FLIP
	# =========================
	if Input.is_action_just_pressed("ui_accept"):
		flip_car()


func is_grounded() -> bool:

	for wheel in wheels:
		if wheel.get_contact_count() > 0:
			return true

	return false


func flip_car():

	rotation = 0
	angular_velocity = 0

	apply_impulse(Vector2(0, -flip_force * 0.1))
