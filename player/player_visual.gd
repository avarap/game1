class_name PlayerVisual
extends AnimatedSprite2D

const DIRECTIONS: Array[StringName] = [&"n", &"ne", &"e", &"se", &"s", &"sw", &"w", &"nw"]
const ACTION_ATLAS := preload("res://art/characters/player/player_actions_64x96.png")
const FRAME_SIZE := Vector2i(64, 96)
const STATE_START := {
	&"idle": 0,
	&"walk": 2,
	&"run": 8,
	&"interact": 14,
}
const STATE_COUNT := {
	&"idle": 2,
	&"walk": 6,
	&"run": 6,
	&"interact": 4,
}
const STATE_SPEED := {
	&"idle": 2.0,
	&"walk": 10.0,
	&"run": 12.0,
	&"interact": 10.0,
}

var _facing := &"s"
var _locomotion_state := &"idle"


func _ready() -> void:
	_build_production_animations()
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


func _build_production_animations() -> void:
	if sprite_frames == null:
		sprite_frames = SpriteFrames.new()
	for state: StringName in STATE_START:
		for direction_index in DIRECTIONS.size():
			_build_animation(state, direction_index)


func _build_animation(state: StringName, direction_index: int) -> void:
	var direction := DIRECTIONS[direction_index]
	var animation_name := StringName("%s_%s" % [state, direction])
	if sprite_frames.has_animation(animation_name):
		sprite_frames.remove_animation(animation_name)
	sprite_frames.add_animation(animation_name)
	sprite_frames.set_animation_loop(animation_name, state != &"interact")
	sprite_frames.set_animation_speed(animation_name, STATE_SPEED[state])

	var start_column: int = STATE_START[state]
	var frame_count: int = STATE_COUNT[state]
	for frame_index in frame_count:
		var texture := AtlasTexture.new()
		texture.atlas = ACTION_ATLAS
		texture.region = Rect2(
			(start_column + frame_index) * FRAME_SIZE.x,
			direction_index * FRAME_SIZE.y,
			FRAME_SIZE.x,
			FRAME_SIZE.y
		)
		sprite_frames.add_frame(animation_name, texture)
