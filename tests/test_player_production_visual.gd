class_name TestPlayerProductionVisual
extends RefCounted

const ACTION_SHEET := "res://art/characters/player/player_actions_64x96.png"
const DIRECTIONS := [&"n", &"ne", &"e", &"se", &"s", &"sw", &"w", &"nw"]
const STATES := [&"idle", &"walk", &"run", &"interact"]
const MINIMUM_FRAMES := {&"idle": 2, &"walk": 6, &"run": 6, &"interact": 4}
const FRAME_SIZE := Vector2i(64, 96)
const SHEET_SIZE := Vector2i(1152, 768)
const EXPECTED_SHEET_SHA256 := "59839543fa0c074898fb4e3b137676729d638784adb769e66990146537193824"
const MINIMUM_OPAQUE_PIXELS := 180
const MINIMUM_SILHOUETTE_HEIGHT := 42
const MINIMUM_OPPOSITE_VIEW_DIFFERENCE_PIXELS := 64
const OPPOSITE_DIRECTION_ROWS := [[1, 7], [2, 6], [3, 5]]
const MINIMUM_SILHOUETTE_WIDTH := {
	&"n": 18,
	&"ne": 18,
	&"e": 16,
	&"se": 18,
	&"s": 16,
	&"sw": 18,
	&"w": 14,
	&"nw": 14,
}


static func run() -> Array[String]:
	var failures: Array[String] = []
	_check_action_sheet_content(failures)
	var packed := load("res://player/player.tscn") as PackedScene
	if packed == null:
		failures.append("Production player scene should load")
		return failures

	var player := packed.instantiate()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(player)
	var body := player.get_node_or_null("Body") as AnimatedSprite2D
	if body == null or body.sprite_frames == null:
		failures.append("Production player should expose Body frames")
		player.free()
		return failures

	if body.offset != Vector2(0, -48):
		failures.append("64x96 player should keep feet pivot at y=0")
	if body.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST:
		failures.append("Player pixel art should use nearest filtering")
	var shadow := player.get_node_or_null("ContactShadow") as Sprite2D
	if shadow == null:
		failures.append("Player should own a contact-shadow node")
	elif shadow.z_index >= body.z_index:
		failures.append("Player contact shadow should draw below the body")

	for direction: StringName in DIRECTIONS:
		for state: StringName in STATES:
			_check_animation(body, state, direction, failures)
	await _check_live_interaction_pose(player, body, failures)

	player.free()
	return failures


static func _check_live_interaction_pose(
	player: PlayerController, body: AnimatedSprite2D, failures: Array[String]
) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var target := Interactable.new()
	target.collision_layer = 2
	target.collision_mask = 0
	target.position = player.position + Vector2(0, 20)
	var target_collider := CollisionShape2D.new()
	var target_shape := CircleShape2D.new()
	target_shape.radius = 4.0
	target_collider.shape = target_shape
	target.add_child(target_collider)
	tree.root.add_child(target)
	player.set_physics_process(false)
	await tree.physics_frame
	await tree.physics_frame

	var event := InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	player._unhandled_input(event)
	var animation := &"interact_s"
	if body.animation != animation:
		failures.append("A real interaction should enter the authored interact_s animation")
		target.free()
		return

	var final_frame := body.sprite_frames.get_frame_count(animation) - 1
	var animation_speed := body.sprite_frames.get_animation_speed(animation)
	var animation_duration := float(final_frame + 1) / animation_speed
	if animation_duration > player.interaction_pose_duration:
		failures.append("All authored interact frames should fit inside the movement lock")
	var sample_time := float(final_frame) / animation_speed + 0.01
	await tree.create_timer(sample_time).timeout
	player._physics_process(sample_time)
	if body.animation != animation:
		failures.append("Interaction visuals should remain active through the movement lock")
	elif body.frame != final_frame:
		failures.append("The final authored interact frame should be visible during gameplay")
	target.free()


static func _check_action_sheet_content(failures: Array[String]) -> void:
	if FileAccess.get_sha256(ACTION_SHEET) != EXPECTED_SHEET_SHA256:
		failures.append("Player action sheet pixels should match the approved authored baseline")
	var texture := load(ACTION_SHEET) as Texture2D
	if texture == null:
		failures.append("Authored player action sheet should load as image data")
		return
	var sheet := texture.get_image()
	if sheet == null or sheet.is_empty():
		failures.append("Authored player action sheet should expose image data")
		return
	if sheet.get_size() != SHEET_SIZE:
		failures.append("Player action sheet should be a complete 18x8 atlas at 1152x768")
		return

	for direction_index in DIRECTIONS.size():
		for column in 18:
			var frame := sheet.get_region(
				Rect2i(column * FRAME_SIZE.x, direction_index * FRAME_SIZE.y, 64, 96)
			)
			var bounds := frame.get_used_rect()
			var frame_name := "%s column %d" % [DIRECTIONS[direction_index], column]
			if (
				bounds.size.x < MINIMUM_SILHOUETTE_WIDTH[DIRECTIONS[direction_index]]
				or bounds.size.y < MINIMUM_SILHOUETTE_HEIGHT
			):
				failures.append("Player frame %s should have a readable silhouette" % frame_name)
				continue

			var opaque_pixels := 0
			var has_partial_alpha := false
			for y in FRAME_SIZE.y:
				for x in FRAME_SIZE.x:
					var alpha := frame.get_pixel(x, y).a
					if alpha >= 1.0:
						opaque_pixels += 1
					elif alpha > 0.0:
						has_partial_alpha = true
			if opaque_pixels < MINIMUM_OPAQUE_PIXELS:
				failures.append(
					"Player frame %s should contain opaque authored pixels" % frame_name
				)
			if has_partial_alpha:
				failures.append("Player frame %s should not contain softened alpha" % frame_name)

	_check_authored_opposite_views(sheet, failures)
	_check_distinct_state_pixels(sheet, failures)


static func _check_authored_opposite_views(sheet: Image, failures: Array[String]) -> void:
	for row_pair in OPPOSITE_DIRECTION_ROWS:
		var right_row := int(row_pair[0])
		var left_row := int(row_pair[1])
		for column in 18:
			var right_frame := sheet.get_region(
				Rect2i(column * FRAME_SIZE.x, right_row * FRAME_SIZE.y, 64, 96)
			)
			right_frame.flip_x()
			var left_frame := sheet.get_region(
				Rect2i(column * FRAME_SIZE.x, left_row * FRAME_SIZE.y, 64, 96)
			)
			var different_pixels := 0
			for y in FRAME_SIZE.y:
				for x in FRAME_SIZE.x:
					if right_frame.get_pixel(x, y) != left_frame.get_pixel(x, y):
						different_pixels += 1
			if different_pixels < MINIMUM_OPPOSITE_VIEW_DIFFERENCE_PIXELS:
				failures.append(
					(
						"Player %s/%s column %d should use independently authored pixels"
						% [DIRECTIONS[right_row], DIRECTIONS[left_row], column]
					)
				)


static func _check_distinct_state_pixels(sheet: Image, failures: Array[String]) -> void:
	for direction_index in DIRECTIONS.size():
		for frame_index in 6:
			var walk_frame := sheet.get_region(
				Rect2i((2 + frame_index) * FRAME_SIZE.x, direction_index * FRAME_SIZE.y, 64, 96)
			)
			var run_frame := sheet.get_region(
				Rect2i((8 + frame_index) * FRAME_SIZE.x, direction_index * FRAME_SIZE.y, 64, 96)
			)
			if walk_frame.get_data() == run_frame.get_data():
				failures.append(
					"Run %s frame %d should not duplicate walk pixels"
					% [DIRECTIONS[direction_index], frame_index]
				)

		var idle_frame := sheet.get_region(
			Rect2i(0, direction_index * FRAME_SIZE.y, 64, 96)
		)
		for interact_column in range(15, 18):
			var interact_frame := sheet.get_region(
				Rect2i(interact_column * FRAME_SIZE.x, direction_index * FRAME_SIZE.y, 64, 96)
			)
			if idle_frame.get_data() == interact_frame.get_data():
				failures.append(
					"Interact %s column %d should not duplicate idle pixels"
					% [DIRECTIONS[direction_index], interact_column]
				)


static func _check_animation(
	body: AnimatedSprite2D, state: StringName, direction: StringName, failures: Array[String]
) -> void:
	var animation := StringName("%s_%s" % [state, direction])
	if not body.sprite_frames.has_animation(animation):
		failures.append("Missing player animation %s" % animation)
		return
	if body.sprite_frames.get_frame_count(animation) < MINIMUM_FRAMES[state]:
		failures.append(
			(
				"Player animation %s should have at least %d authored frames"
				% [animation, MINIMUM_FRAMES[state]]
			)
		)
		return
	for frame_index in body.sprite_frames.get_frame_count(animation):
		var texture := body.sprite_frames.get_frame_texture(animation, frame_index)
		if texture == null or texture.get_size() != Vector2(64, 96):
			failures.append("Player animation %s contains a non-64x96 frame" % animation)
			return
		if texture is not AtlasTexture:
			failures.append("Player animation %s must use authored atlas regions" % animation)
			return
		var atlas_texture := texture as AtlasTexture
		if atlas_texture.atlas == null or atlas_texture.atlas.resource_path != ACTION_SHEET:
			failures.append(
				"Player animation %s must come from the authored action sheet" % animation
			)
			return


