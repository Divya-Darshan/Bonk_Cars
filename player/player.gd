extends RigidBody2D

@export var engine_force: float = 1000.0
@export var reverse_force: float = 900.0
@export var air_spin_force: float = 250000.0
@export var jump_force: float = 50000.0

@export var wheelie_torque: float = 69600.0 + 191000.0 - 39000.0

@export var wobble_strength: float = 500000.0
@export var bounce_force: float = 100000.0
@export var sideways_chaos: float = 40000.0


func player(): 
	#this function is for communicating with the pickups dont remove it!!!!
	pass 



func _physics_process(delta):

	# Forward
	if Input.is_action_pressed("ui_up"):
		apply_central_force(Vector2.RIGHT.rotated(rotation) * engine_force)
		apply_torque(-wheelie_torque) # lifts front

	# Reverse
	if Input.is_action_pressed("ui_down"):
		apply_central_force(Vector2.LEFT.rotated(rotation) * reverse_force)
		apply_torque(wheelie_torque) # lifts back

	# Air spin
	if Input.is_action_pressed("ui_left"):
		apply_torque(-air_spin_force)

	if Input.is_action_pressed("ui_right"):
		apply_torque(air_spin_force)

	# Jump
	if Input.is_action_just_pressed("ui_accept"):
		apply_impulse(Vector2.ZERO, Vector2.UP * -jump_force)

	# CHAOTIC WOBBLE
	var wobble = randf_range(-wobble_strength, wobble_strength)
	apply_torque(wobble * delta)

	# Random suspension bounce
	if randf() < 0.05:
		apply_impulse(Vector2.ZERO, Vector2.UP * -bounce_force)

	# Random sideways chaos
	if randf() < 0.04:
		var chaos = randf_range(-sideways_chaos, sideways_chaos)
		apply_impulse(Vector2.ZERO, Vector2(chaos, 0))
