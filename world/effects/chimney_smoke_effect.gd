class_name ChimneySmokeEffect
extends CPUParticles2D

func _ready() -> void:
	emitting = true
	amount = 14
	lifetime = 2.4
	one_shot = false
	speed_scale = 1.0
	explosiveness = 0.0
	randomness = 0.3
	
	# Emission direction: rising up and drifting slightly right
	direction = Vector2(0.35, -1.0)
	spread = 18.0
	gravity = Vector2(4.0, -14.0)
	
	# Velocities
	initial_velocity_min = 18.0
	initial_velocity_max = 28.0
	angular_velocity_min = -20.0
	angular_velocity_max = 20.0
	
	# Scale expansion over time
	scale_amount_min = 2.0
	scale_amount_max = 5.0
	
	# Soft warm grey smoke tint fading out over lifetime
	color = Color(0.85, 0.82, 0.78, 0.45)
