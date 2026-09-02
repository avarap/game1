class_name PlayerVisual
extends AnimatedSprite2D

const RUN_ANIMATION_SPEED_SCALE := 1.45


func _process(_delta: float) -> void:
	var actor := get_parent() as PlayerController
	if actor == null:
		return

	var facing := actor.get_facing_name()
	var animation_prefix := &"idle"
	speed_scale = 1.0

	match actor.get_state():
		PlayerController.State.WALK:
			animation_prefix = &"walk"
		PlayerController.State.RUN:
			animation_prefix = &"walk"
			speed_scale = RUN_ANIMATION_SPEED_SCALE
		PlayerController.State.INTERACT:
			animation_prefix = &"idle"
		_:
			animation_prefix = &"idle"

	var target := StringName("%s_%s" % [animation_prefix, facing])
	if animation != target:
		play(target)
