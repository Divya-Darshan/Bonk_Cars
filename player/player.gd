extends RigidBody2D

@export var engine_force: float = 4000.0   # 🔥 MUCH faster
@export var reverse_force: float = 4000.0  # same speed both sides
@export var air_spin_force: float = 5000.0
@export var jump_force: float = 700.0

@export var wheelie_torque: float = 1600000

@export var wobble_strength: float = 800.0
@export var bounce_force: float = 400.0
@export var sideways_chaos: float = 800.0

# ⏱️ Hold timers
var forward_hold_time := 1.0
var reverse_hold_time := 1.0


func player(): 
	pass 


func _ready():
	linear_damp = 0.2   
	angular_damp = 0.2


func _physics_process(delta):

	# 🚀 FORWARD
	if Input.is_action_pressed("d"):
		forward_hold_time += delta
		
		# instant strong acceleration
		apply_central_force(Vector2.RIGHT.rotated(rotation) * engine_force)

		# ⏱️ Wheelie after 2 seconds
		if forward_hold_time > 2.0:
			apply_torque(-wheelie_torque)

	else:
		forward_hold_time = 0.0


	# 🔙 REVERSE
	if Input.is_action_pressed("a"):
		reverse_hold_time += delta
		
		apply_central_force(Vector2.LEFT.rotated(rotation) * reverse_force)

		# ⏱️ Back lift after 2 seconds
		if reverse_hold_time > 2.0:
			apply_torque(wheelie_torque)

	else:
		reverse_hold_time = 0.0


	# 🔄 AIR CONTROL
	if Input.is_action_pressed("ui_left"):
		apply_torque(-air_spin_force)

	if Input.is_action_pressed("ui_right"):
		apply_torque(air_spin_force)


	# 🚀 JUMP
	if Input.is_action_just_pressed("ui_accept"):
		apply_impulse(Vector2.ZERO, Vector2.UP * -jump_force)
		apply_impulse(Vector2.ZERO, Vector2.RIGHT.rotated(rotation) * 300)


	# 🎢 LIGHT wobble (less annoying)
	var wobble = randf_range(-wobble_strength, wobble_strength)
	apply_torque(wobble * delta)


	# 💥 Rare chaos
	if randf() < 0.01:
		apply_impulse(Vector2.ZERO, Vector2.UP * -bounce_force)

	if randf() < 0.01:
		var chaos = randf_range(-sideways_chaos, sideways_chaos)
		apply_impulse(Vector2.ZERO, Vector2(chaos, 0))
