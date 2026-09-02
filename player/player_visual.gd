class_name PlayerVisual
extends AnimatedSprite2D

const RUN_ANIMATION_SPEED := 10.0
const INTERACT_ANIMATION_SPEED := 12.0


func _ready() -> void:
	prepare_state_animations()


func prepare_state_animations() -> void:
	if sprite_frames == null:
		return
	for facing in PlayerMovement.DIRECTION_NAMES:
		_prepare_run_animation(facing)
		_prepare_interact_animation(facing)


func _process(_delta: float) -> void:
	var actor := get_parent() as PlayerController
	if actor == null:
		return

	var facing := actor.get_facing_name()
	var animation_prefix := &"idle"

	match actor.get_state():
		PlayerController.State.WALK:
			animation_prefix = &"walk"
		PlayerController.State.RUN:
			animation_prefix = &"run"
		PlayerController.State.INTERACT:
			animation_prefix = &"interact"
		_:
			animation_prefix = &"idle"

	var target := StringName("%s_%s" % [animation_prefix, facing])
	if animation != target:
		play(target)


func _prepare_run_animation(facing: StringName) -> void:
	var source := StringName("walk_%s" % facing)
	var target := StringName("run_%s" % facing)
	if sprite_frames.has_animation(target) or not sprite_frames.has_animation(source):
		return

	sprite_frames.add_animation(target)
	sprite_frames.set_animation_speed(target, RUN_ANIMATION_SPEED)
	sprite_frames.set_animation_loop(target, true)
	for frame_index in sprite_frames.get_frame_count(source):
		var texture := sprite_frames.get_frame_texture(source, frame_index)
		var duration := sprite_frames.get_frame_duration(source, frame_index)
		sprite_frames.add_frame(target, texture, duration)


func _prepare_interact_animation(facing: StringName) -> void:
	var idle := StringName("idle_%s" % facing)
	var walk := StringName("walk_%s" % facing)
	var target := StringName("interact_%s" % facing)
	if sprite_frames.has_animation(target):
		return
	if not sprite_frames.has_animation(idle) or not sprite_frames.has_animation(walk):
		return

	sprite_frames.add_animation(target)
	sprite_frames.set_animation_speed(target, INTERACT_ANIMATION_SPEED)
	sprite_frames.set_animation_loop(target, false)
	var idle_texture := sprite_frames.get_frame_texture(idle, 0)
	var reach_texture := sprite_frames.get_frame_texture(walk, 0)
	sprite_frames.add_frame(target, idle_texture, 0.7)
	sprite_frames.add_frame(target, reach_texture, 0.6)
	sprite_frames.add_frame(target, idle_texture, 0.7)
