extends RigidBody2D

var wheels := []
@export var speed := 60000.0

func _ready():
	# Get all wheels in group "wheel"
	wheels = get_tree().get_nodes_in_group("wheel")

func _physics_process(delta):
	var dir := Input.get_axis("ui_left", "ui_right")

	if abs(dir) > 0.01:
		for wheel in wheels:
			wheel.apply_torque_impulse(dir * speed * delta)
