extends RigidBody2D

@export var engine_force: float = 5000.0
@export var reverse_force: float = 5000.0
@export var air_spin_force: float = 200.0
@export var jump_force: float = 1200.0

@export var wheelie_torque: float = 1500000.0   # reduced from 2000000

@export var wobble_strength: float = 600.0
@export var bounce_force: float = 400.0
@export var sideways_chaos: float = 40000.0
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

var smoke_delay := 0.0
var smoke_alpha := 0.0
var smooth_stretch := 0.0
var forward_hold_time := 0.0
var reverse_hold_time := 0.0


func player(): 
	pass 
	
func _process(delta: float) -> void:
	var is_moving := Input.is_action_pressed("d") or Input.is_action_pressed("a")

	# Delay logic
	if is_moving:
		smoke_delay += delta
	else:
		smoke_delay = 0.0

	var should_emit := smoke_delay > .5

	# Fade logic
	if should_emit:
		smoke_alpha = lerp(smoke_alpha, 1.0, 3 * delta)
	else:
		smoke_alpha = lerp(smoke_alpha, 0.0, 5 * delta)

	# Apply emission
	cpu_particles_2d.emitting = smoke_alpha > 0.05

	var c = cpu_particles_2d.modulate
	c.a = smoke_alpha
	cpu_particles_2d.modulate = c

	# Direction
	if linear_velocity.x > 0:
		cpu_particles_2d.direction = Vector2.LEFT
	elif linear_velocity.x < 0:
		cpu_particles_2d.direction = Vector2.RIGHT

	# Smooth stretch
	var speed: float = abs(linear_velocity.x) / 300.0
	var target_stretch: float = clamp(speed, 0.0, 1.5)
	smooth_stretch = lerp(smooth_stretch, target_stretch, 5 * delta)

	cpu_particles_2d.scale = Vector2(1.0 + smooth_stretch, 1.0 - smooth_stretch * 0.3)
func _ready():
	linear_damp = 0.35
	angular_damp = 0.3   # slightly higher = more control




func _physics_process(delta):
	
	if is_multiplayer_authority():

		# Forward (balanced lift)
		if Input.is_action_pressed("d"):
			forward_hold_time += delta
			apply_central_force(Vector2.RIGHT.rotated(rotation) * engine_force)
			# small instant lift (reduced)
			apply_torque(-wheelie_torque * 0.1)
			# smoother buildup
			if forward_hold_time > 0.4:
				var t = clamp((forward_hold_time - 0.4) / 0.7, 0, 1)
				apply_torque(-wheelie_torque * t)
		else:
			forward_hold_time = 0.0
		# Reverse (balanced lift)
		if Input.is_action_pressed("a"):
			reverse_hold_time += delta
			apply_central_force(Vector2.LEFT.rotated(rotation) * reverse_force)
			apply_torque(wheelie_torque * 0.1)
			if reverse_hold_time > 0.4:
				var t = clamp((reverse_hold_time - 0.4) / 0.7, 0, 1)
				apply_torque(wheelie_torque * t)

		else:
			reverse_hold_time = 0.0
		# Air control
		if Input.is_action_pressed("ui_left"):
			apply_torque(-air_spin_force)
		if Input.is_action_pressed("ui_right"):
			apply_torque(air_spin_force)
		# Jump
		if Input.is_action_just_pressed("ui_accept"):
			apply_impulse(Vector2.ZERO, Vector2.UP * -jump_force)
			apply_impulse(Vector2.ZERO, Vector2.RIGHT.rotated(rotation) * 300)
		# Wobble
		var wobble = randf_range(-wobble_strength, wobble_strength)
		apply_torque(wobble * delta)
		# Rare bounce
		if randf() < 0.01:
			apply_impulse(Vector2.ZERO, Vector2.UP * -bounce_force)
		# Rare sideways chaos
		if randf() < 0.01:
			var chaos = randf_range(-sideways_chaos, sideways_chaos)
			apply_impulse(Vector2.ZERO, Vector2(chaos, 0))




func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	
