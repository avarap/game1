class_name PlayerVisual
extends AnimatedSprite2D

const DIRECTIONS: Array[StringName] = [&"n", &"ne", &"e", &"se", &"s", &"sw", &"w", &"nw"]
const FRAME_SIZE := Vector2i(64, 96)
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
const DIRECTION_VECTORS: Array[Vector2] = [
	Vector2.UP,
	Vector2(1.0, -1.0).normalized(),
	Vector2.RIGHT,
	Vector2(1.0, 1.0).normalized(),
	Vector2.DOWN,
	Vector2(-1.0, 1.0).normalized(),
	Vector2.LEFT,
	Vector2(-1.0, -1.0).normalized(),
]
const OUTLINE := Color8(39, 32, 30)
const HAIR := Color8(63, 48, 40)
const HAIR_HIGHLIGHT := Color8(88, 66, 52)
const SKIN := Color8(184, 137, 103)
const SHIRT := Color8(110, 116, 83)
const SHIRT_HIGHLIGHT := Color8(139, 142, 99)
const VEST := Color8(90, 66, 47)
const VEST_HIGHLIGHT := Color8(121, 87, 59)
const BELT := Color8(62, 45, 35)
const METAL := Color8(139, 143, 134)
const PANTS := Color8(72, 74, 66)
const BOOTS := Color8(55, 42, 35)
const ACTION_ACCENT := Color8(129, 78, 54)

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


func _apply_animation() -> void:
	if sprite_frames == null:
		return
	var target := StringName("%s_%s" % [_locomotion_state, _facing])
	if not sprite_frames.has_animation(target):
		target = StringName("idle_%s" % _facing)
	if animation != target:
		play(target)
	speed_scale = 1.0


func _build_production_animations() -> void:
	sprite_frames = SpriteFrames.new()
	for state: StringName in STATE_COUNT:
		for direction_index in DIRECTIONS.size():
			_build_animation(state, direction_index)


func _build_animation(state: StringName, direction_index: int) -> void:
	var direction := DIRECTIONS[direction_index]
	var animation_name := StringName("%s_%s" % [state, direction])
	sprite_frames.add_animation(animation_name)
	sprite_frames.set_animation_loop(animation_name, state != &"interact")
	sprite_frames.set_animation_speed(animation_name, STATE_SPEED[state])

	var frame_count: int = STATE_COUNT[state]
	for frame_index in frame_count:
		sprite_frames.add_frame(
			animation_name,
			_render_frame(state, direction_index, frame_index)
		)


func _render_frame(state: StringName, direction_index: int, frame_index: int) -> Texture2D:
	var image := Image.create(FRAME_SIZE.x, FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var direction := DIRECTION_VECTORS[direction_index]
	var pose := _pose_for(state, frame_index)
	var stride: int = pose.x
	var bob: int = pose.y
	var lean := 2 if state == &"run" else 0
	var center_x := 32 + int(direction.x * lean)
	var foot_y := 89 + bob
	var hip_y := 68 + bob
	var shoulder_y := 43 + bob
	var head_y := 23 + bob

	_draw_legs(image, center_x, hip_y, foot_y, direction, stride)
	_draw_torso(image, center_x, shoulder_y, hip_y, direction, lean)
	_draw_arms(image, center_x, shoulder_y, direction, state, stride, frame_index)
	_draw_head(image, center_x, head_y, direction, lean)
	if state == &"run":
		_draw_run_tail(image, center_x, hip_y, direction)
	return ImageTexture.create_from_image(image)


func _pose_for(state: StringName, frame_index: int) -> Vector2i:
	if state == &"idle":
		return Vector2i(0, [0, 1][frame_index])
	if state == &"walk":
		return Vector2i([-3, -1, 2, 3, 1, -2][frame_index], [0, 1, 0, -1, 0, 1][frame_index])
	if state == &"run":
		return Vector2i([-6, -3, 3, 6, 3, -3][frame_index], [1, -1, 0, 1, -1, 0][frame_index])
	return Vector2i(0, [0, -1, -1, 0][frame_index])


func _draw_legs(
	image: Image,
	center_x: int,
	hip_y: int,
	foot_y: int,
	direction: Vector2,
	stride: int
) -> void:
	for leg_index in 2:
		var leg_stride := stride if leg_index == 0 else -stride
		var side_x := -6 if leg_index == 0 else 6
		var foot_x := center_x + side_x + int(direction.x * leg_stride * 0.55)
		var foot_offset_y := int(absf(direction.y) * leg_stride * 0.25)
		var leg_x := center_x - 8 if leg_index == 0 else center_x + 2
		_fill_rect(image, Rect2i(leg_x, hip_y - 1, 7, 19), OUTLINE)
		_fill_rect(image, Rect2i(leg_x + 2, hip_y + 1, 4, 16), PANTS)
		_fill_rect(image, Rect2i(foot_x - 4, foot_y - 11 + foot_offset_y, 9, 12), OUTLINE)
		_fill_rect(image, Rect2i(foot_x - 3, foot_y - 8 + foot_offset_y, 8, 8), BOOTS)


func _draw_torso(
	image: Image,
	center_x: int,
	shoulder_y: int,
	hip_y: int,
	direction: Vector2,
	lean: int
) -> void:
	var shift := int(direction.x * lean)
	_fill_rect(image, Rect2i(center_x - 18 + shift, shoulder_y, 36, 26), OUTLINE)
	_fill_rect(image, Rect2i(center_x - 15 + shift, shoulder_y + 2, 30, 22), SHIRT)
	_fill_rect(image, Rect2i(center_x - 9 + shift, shoulder_y + 5, 18, 18), VEST)
	_fill_rect(image, Rect2i(center_x - 7 + shift, shoulder_y + 6, 3, 15), VEST_HIGHLIGHT)
	_fill_rect(image, Rect2i(center_x - 12, hip_y - 7, 24, 5), OUTLINE)
	_fill_rect(image, Rect2i(center_x - 10, hip_y - 6, 20, 3), BELT)
	_fill_rect(image, Rect2i(center_x - 1, hip_y - 7, 4, 4), METAL)
	_fill_rect(image, Rect2i(center_x - 14 + shift, shoulder_y + 3, 9, 2), SHIRT_HIGHLIGHT)


func _draw_arms(
	image: Image,
	center_x: int,
	shoulder_y: int,
	direction: Vector2,
	state: StringName,
	stride: int,
	frame_index: int
) -> void:
	var left_end := Vector2i(center_x - 15, shoulder_y + 24)
	var right_end := Vector2i(center_x + 15, shoulder_y + 24)
	if state == &"walk" or state == &"run":
		left_end.y += int(stride * 0.45)
		right_end.y -= int(stride * 0.45)
		left_end.x -= int(direction.x * stride * 0.35)
		right_end.x += int(direction.x * stride * 0.35)
	elif state == &"interact":
		var reach: int = [0, 4, 8, 3][frame_index]
		right_end.x += int(direction.x * reach)
		right_end.y += int(direction.y * reach * 0.55)

	_draw_arm(image, Vector2i(center_x - 16, shoulder_y + 5), left_end)
	_draw_arm(image, Vector2i(center_x + 16, shoulder_y + 5), right_end)
	if state == &"interact" and frame_index > 0:
		_draw_interaction_prop(image, right_end, direction)


func _draw_arm(image: Image, start: Vector2i, finish: Vector2i) -> void:
	var midpoint := Vector2i((start.x + finish.x) / 2, (start.y + finish.y) / 2)
	_fill_rect(image, Rect2i(midpoint.x - 3, midpoint.y - 8, 7, 17), OUTLINE)
	_fill_rect(image, Rect2i(midpoint.x - 1, midpoint.y - 6, 3, 14), SHIRT_HIGHLIGHT)
	_fill_rect(image, Rect2i(finish.x - 3, finish.y - 3, 7, 7), OUTLINE)
	_fill_rect(image, Rect2i(finish.x - 2, finish.y - 2, 5, 5), SKIN)


func _draw_interaction_prop(image: Image, hand: Vector2i, direction: Vector2) -> void:
	var prop_x := hand.x + int(direction.x * 7.0)
	var prop_y := hand.y + int(direction.y * 5.0)
	_fill_rect(image, Rect2i(prop_x - 2, prop_y - 2, 5, 10), OUTLINE)
	_fill_rect(image, Rect2i(prop_x - 1, prop_y - 1, 3, 8), ACTION_ACCENT)
	_fill_rect(image, Rect2i(prop_x - 1, prop_y - 2, 3, 2), METAL)


func _draw_head(
	image: Image,
	center_x: int,
	head_y: int,
	direction: Vector2,
	lean: int
) -> void:
	var head_x := center_x + int(direction.x * (3 + lean))
	_fill_rect(image, Rect2i(head_x - 10, head_y - 7, 21, 22), OUTLINE)
	_fill_rect(image, Rect2i(head_x - 8, head_y - 5, 17, 18), SKIN)
	_fill_rect(image, Rect2i(head_x - 8, head_y - 5, 17, 7), HAIR)
	_fill_rect(image, Rect2i(head_x - 6, head_y - 4, 10, 2), HAIR_HIGHLIGHT)
	if direction.y >= 0.0:
		var eye_x := head_x + int(direction.x * 3.0)
		_fill_rect(image, Rect2i(eye_x - 1, head_y + 4, 3, 2), OUTLINE)
		_fill_rect(image, Rect2i(head_x - 4, head_y + 9, 9, 2), HAIR)


func _draw_run_tail(image: Image, center_x: int, hip_y: int, direction: Vector2) -> void:
	var trail_x := center_x - int(direction.x * 9.0)
	var trail_y := hip_y - 10 - int(direction.y * 2.0)
	_fill_rect(image, Rect2i(trail_x - 4, trail_y, 9, 8), OUTLINE)
	_fill_rect(image, Rect2i(trail_x - 3, trail_y + 1, 7, 6), ACTION_ACCENT)


func _fill_rect(image: Image, rect: Rect2i, color: Color) -> void:
	image.fill_rect(rect, color)
