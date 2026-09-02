class_name PlayerVisual
extends AnimatedSprite2D

const RUN_ANIMATION_SCALE := 1.35

var _facing := &"s"
var _locomotion_state := &"idle"


func set_locomotion_state(state: StringName, facing_vector: Vector2) -> void:
	_locomotion_state = state
	if not facing_vector.is_zero_approx():
		_facing = PlayerMovement.direction_name(facing_vector)
	_apply_animation()


func get_facing_name() -> StringName:
	return _facing


func get_locomotion_state() -> StringName:
	return _locomotion_state


func _apply_animation() -> void:
	var animation_state := _locomotion_state
	if _locomotion_state == &"run":
		animation_state = &"walk"
	elif _locomotion_state == &"interact":
		animation_state = &"interact"

	var target := StringName("%s_%s" % [animation_state, _facing])
	if not sprite_frames.has_animation(target):
		target = StringName("idle_%s" % _facing)

	var target_speed_scale := RUN_ANIMATION_SCALE if _locomotion_state == &"run" else 1.0
	if animation != target:
		play(target)
	speed_scale = target_speed_scale
