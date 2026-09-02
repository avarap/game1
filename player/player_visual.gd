class_name PlayerVisual
extends AnimatedSprite2D

const RUN_FPS := 10.0
const INTERACT_FPS := 12.0
const DIRECTIONS: Array[StringName] = [&"n", &"ne", &"e", &"se", &"s", &"sw", &"w", &"nw"]

var _facing := &"s"
var _locomotion_state := &"idle"


func _ready() -> void:
	_ensure_state_animations()
	_apply_animation()


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
	var target := StringName("%s_%s" % [_locomotion_state, _facing])
	if not sprite_frames.has_animation(target):
		target = StringName("idle_%s" % _facing)

	if animation != target:
		play(target)
	speed_scale = 1.0


func _ensure_state_animations() -> void:
	if sprite_frames == null:
		return

	for direction in DIRECTIONS:
		_ensure_run_animation(direction)
		_ensure_interact_animation(direction)


func _ensure_run_animation(direction: StringName) -> void:
	var target := StringName("run_%s" % direction)
	if sprite_frames.has_animation(target):
		return

	var source := StringName("walk_%s" % direction)
	if not sprite_frames.has_animation(source):
		return

	sprite_frames.add_animation(target)
	sprite_frames.set_animation_loop(target, true)
	sprite_frames.set_animation_speed(target, RUN_FPS)
	_copy_frames(source, target)


func _ensure_interact_animation(direction: StringName) -> void:
	var target := StringName("interact_%s" % direction)
	if sprite_frames.has_animation(target):
		return

	var idle_source := StringName("idle_%s" % direction)
	var walk_source := StringName("walk_%s" % direction)
	if not sprite_frames.has_animation(idle_source):
		return

	sprite_frames.add_animation(target)
	sprite_frames.set_animation_loop(target, false)
	sprite_frames.set_animation_speed(target, INTERACT_FPS)

	var idle_texture := sprite_frames.get_frame_texture(idle_source, 0)
	if idle_texture != null:
		sprite_frames.add_frame(target, idle_texture)

	if sprite_frames.has_animation(walk_source) and sprite_frames.get_frame_count(walk_source) > 1:
		var reach_texture := sprite_frames.get_frame_texture(walk_source, 1)
		if reach_texture != null:
			sprite_frames.add_frame(target, reach_texture)


func _copy_frames(source: StringName, target: StringName) -> void:
	for frame_index in sprite_frames.get_frame_count(source):
		var texture := sprite_frames.get_frame_texture(source, frame_index)
		var duration := sprite_frames.get_frame_duration(source, frame_index)
		if texture != null:
			sprite_frames.add_frame(target, texture, duration)
