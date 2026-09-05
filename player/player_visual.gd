class_name PlayerVisual
extends AnimatedSprite2D

const ACTION_SHEET := preload("res://art/characters/player/player_actions_64x96.png")
const DIRECTIONS: Array[StringName] = [&"n", &"ne", &"e", &"se", &"s", &"sw", &"w", &"nw"]
const FRAME_SIZE := Vector2i(64, 96)
const STATE_LAYOUT := {
	&"idle": {"column": 0, "count": 2, "speed": 2.0, "loop": true},
	&"walk": {"column": 2, "count": 6, "speed": 10.0, "loop": true},
	&"run": {"column": 8, "count": 6, "speed": 12.0, "loop": true},
	&"interact": {"column": 14, "count": 4, "speed": 24.0, "loop": false},
}

var _facing := &"s"
var _locomotion_state := &"idle"


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_bind_authored_atlas()
	_apply_animation()


func set_locomotion_state(state: StringName, facing_vector: Vector2) -> void:
	_locomotion_state = state
	if not facing_vector.is_zero_approx():
		_facing = PlayerMovement.direction_name(facing_vector)
	_apply_animation()


func _apply_animation() -> void:
	if sprite_frames == null:
		return
	var target := StringName("%s_%s" % [_locomotion_state, _facing])
	if not sprite_frames.has_animation(target):
		push_error("Missing authored player animation %s" % target)
		return
	if animation != target:
		play(target)
	speed_scale = 1.0


func _bind_authored_atlas() -> void:
	sprite_frames = SpriteFrames.new()
	for state: StringName in STATE_LAYOUT:
		var layout: Dictionary = STATE_LAYOUT[state]
		for direction_index in DIRECTIONS.size():
			var animation_name := StringName("%s_%s" % [state, DIRECTIONS[direction_index]])
			sprite_frames.add_animation(animation_name)
			sprite_frames.set_animation_loop(animation_name, bool(layout["loop"]))
			sprite_frames.set_animation_speed(animation_name, float(layout["speed"]))
			for frame_index in int(layout["count"]):
				var frame := AtlasTexture.new()
				frame.atlas = ACTION_SHEET
				frame.region = Rect2(
					(int(layout["column"]) + frame_index) * FRAME_SIZE.x,
					direction_index * FRAME_SIZE.y,
					FRAME_SIZE.x,
					FRAME_SIZE.y
				)
				sprite_frames.add_frame(animation_name, frame)
