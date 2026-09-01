extends SceneTree

const FRAME_SIZE := Vector2i(64, 96)
const DIRECTIONS := ["n", "ne", "e", "se", "s", "sw", "w", "nw"]


func _initialize() -> void:
	_generate_sheet("res://art/characters/player/player_idle_walk_64x96.png", false)
	_generate_sheet("res://art/characters/npcs/brother_aldren_idle_walk_64x96.png", true)
	_generate_shadow()
	quit()


func _generate_sheet(path: String, aldren: bool) -> void:
	var image := Image.create(FRAME_SIZE.x * 5, FRAME_SIZE.y * 8, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for row in DIRECTIONS.size():
		for frame in 5:
			_draw_character(image, Vector2i(frame * 64, row * 96), row, frame, aldren)
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save character atlas: %s" % path)


func _draw_character(
	image: Image, origin: Vector2i, direction: int, frame: int, aldren: bool
) -> void:
	var phase := 0 if frame == 0 else frame - 1
	var bob: int = 0 if frame == 0 else [0, -2, 0, 1][phase]
	var stride: int = 0 if frame == 0 else [-4, -1, 4, 1][phase]
	var dx: int = [0, 1, 1, 1, 0, -1, -1, -1][direction]
	var dy: int = [-1, -1, 0, 1, 1, 1, 0, -1][direction]
	var center := origin + Vector2i(32, 89 + bob)
	if aldren:
		_draw_aldren(image, center, dx, dy, stride, phase)
	else:
		_draw_keeper(image, center, dx, dy, stride, phase)


func _draw_keeper(image: Image, feet: Vector2i, dx: int, dy: int, stride: int, phase: int) -> void:
	var outline := Color("252824")
	var boot_dark := Color("352b24")
	var boot_light := Color("6b4a31")
	var coat_dark := Color("273b38")
	var coat_mid := Color("3e5b52")
	var coat_light := Color("66806c")
	var leather_dark := Color("493323")
	var leather := Color("795338")
	var shirt := Color("b8aa83")
	var skin_dark := Color("8d5741")
	var skin := Color("c88762")
	var skin_light := Color("e5ad7d")
	var hair := Color("4a3026")
	var hair_light := Color("76503a")
	var metal_dark := Color("566064")
	var metal := Color("a4b0aa")
	var accent := Color("b98338")

	var sideways: int = absi(dx)
	var leg_y := feet.y - 20
	var left_x := feet.x - 8 + (stride if sideways == 0 else stride / 2)
	var right_x := feet.x + 3 - (stride if sideways == 0 else stride / 2)
	_rect(image, Rect2i(left_x - 1, leg_y, 8, 18), outline)
	_rect(image, Rect2i(right_x - 1, leg_y, 8, 18), outline)
	_rect(image, Rect2i(left_x, leg_y + 2, 6, 13), leather_dark)
	_rect(image, Rect2i(right_x, leg_y + 2, 6, 13), leather)
	_rect(image, Rect2i(left_x - 2 + dx * 2, feet.y - 5, 10, 5), boot_dark)
	_rect(image, Rect2i(right_x - 1 + dx * 2, feet.y - 5, 10, 5), boot_dark)
	_rect(image, Rect2i(left_x + dx * 2, feet.y - 5, 5, 2), boot_light)

	var torso := Vector2i(feet.x + dx * 2, feet.y - 43)
	_rect(image, Rect2i(torso.x - 15, torso.y - 14, 30, 30), outline)
	_rect(image, Rect2i(torso.x - 13, torso.y - 12, 26, 27), coat_dark)
	_rect(image, Rect2i(torso.x - 10, torso.y - 11, 12, 25), coat_mid)
	_rect(image, Rect2i(torso.x - 8, torso.y - 10, 5, 20), coat_light)
	_rect(image, Rect2i(torso.x - 13, torso.y - 12, 5, 8), leather_dark)
	_rect(image, Rect2i(torso.x - 12, torso.y - 11, 3, 6), leather)
	_rect(image, Rect2i(torso.x - 14, torso.y + 10, 29, 6), outline)
	_rect(image, Rect2i(torso.x - 11, torso.y + 9, 10, 8), coat_mid)
	_rect(image, Rect2i(torso.x + 2, torso.y + 9, 10, 8), coat_dark)
	_rect(image, Rect2i(torso.x - 15, torso.y + 4, 30, 4), leather_dark)
	_rect(image, Rect2i(torso.x - 12, torso.y + 5, 24, 2), leather)
	_rect(image, Rect2i(torso.x + 5, torso.y + 3, 5, 6), accent)
	if dy >= 0:
		_rect(image, Rect2i(torso.x - 4, torso.y - 9, 8, 13), shirt)
		_rect(image, Rect2i(torso.x - 1, torso.y - 8, 2, 12), coat_dark)
		_rect(image, Rect2i(torso.x - 8, torso.y - 6, 5, 12), coat_light)
		_rect(image, Rect2i(torso.x + 4, torso.y - 6, 5, 12), coat_mid)
	else:
		_rect(image, Rect2i(torso.x - 10, torso.y - 10, 20, 4), coat_light)
	_rect(image, Rect2i(torso.x - 10, torso.y + 8, 20, 2), coat_light)
	_rect(image, Rect2i(torso.x - 7, torso.y + 11, 3, 3), accent)

	var arm_swing: int = [2, -2, -2, 2][phase]
	var arm_y := torso.y - 8
	_rect(image, Rect2i(torso.x - 20, arm_y + arm_swing, 8, 24), outline)
	_rect(image, Rect2i(torso.x - 18, arm_y + arm_swing + 2, 5, 18), coat_mid)
	_rect(image, Rect2i(torso.x + 12, arm_y - arm_swing, 8, 24), outline)
	_rect(image, Rect2i(torso.x + 13, arm_y - arm_swing + 2, 5, 18), coat_dark)
	_rect(image, Rect2i(torso.x - 17, arm_y + arm_swing + 19, 5, 5), skin)
	_rect(image, Rect2i(torso.x + 14, arm_y - arm_swing + 19, 5, 5), skin_dark)

	var head := Vector2i(torso.x + dx * 2, torso.y - 27 + dy * 2)
	_rect(image, Rect2i(head.x - 9, head.y - 13, 18, 25), outline)
	_rect(image, Rect2i(head.x - 12, head.y - 9, 24, 16), outline)
	_rect(image, Rect2i(head.x - 9, head.y - 9, 18, 19), skin_dark)
	_rect(image, Rect2i(head.x - 8, head.y - 8, 14, 16), skin)
	_rect(image, Rect2i(head.x - 6, head.y - 8, 7, 5), skin_light)
	_rect(image, Rect2i(head.x - 10, head.y - 14, 20, 7), hair)
	_rect(image, Rect2i(head.x - 13, head.y - 9, 26, 4), outline)
	_rect(image, Rect2i(head.x - 11, head.y - 10, 22, 3), hair_light)
	_rect(image, Rect2i(head.x - 8, head.y - 13, 10, 3), hair_light)
	if dy >= 0:
		_rect(image, Rect2i(head.x - 6 + dx * 3, head.y, 3, 2), outline)
		_rect(image, Rect2i(head.x + 3 + dx * 3, head.y, 3, 2), outline)
		_rect(image, Rect2i(head.x + dx * 3, head.y + 2, 4, 3), skin_light)
		_rect(image, Rect2i(head.x - 6 + dx * 2, head.y + 6, 13, 5), hair)
		_rect(image, Rect2i(head.x - 2 + dx * 2, head.y + 6, 5, 3), hair_light)
	else:
		_rect(image, Rect2i(head.x - 9, head.y - 3, 18, 9), hair)

	var tool_x := torso.x + 22
	_line(image, Vector2i(tool_x, torso.y - 14), Vector2i(tool_x + dx * 3, feet.y - 3), leather)
	_rect(image, Rect2i(tool_x - 4 + dx * 3, torso.y - 18, 12, 5), metal_dark)
	_rect(image, Rect2i(tool_x - 2 + dx * 3, torso.y - 18, 8, 2), metal)
	_rect(image, Rect2i(torso.x - 20, torso.y + 3, 8, 13), leather_dark)
	_rect(image, Rect2i(torso.x - 18, torso.y + 5, 5, 8), leather)
	_rect(image, Rect2i(torso.x - 17, torso.y + 5, 3, 2), accent)


func _draw_aldren(image: Image, feet: Vector2i, dx: int, dy: int, stride: int, phase: int) -> void:
	var outline := Color("292824")
	var robe_dark := Color("352f3c")
	var robe_mid := Color("51475b")
	var robe_light := Color("75677a")
	var trim := Color("9b885e")
	var skin_dark := Color("8a6252")
	var skin := Color("bd8a70")
	var skin_light := Color("d7ad8c")
	var hair := Color("b8b2a1")
	var hair_dark := Color("716e67")
	var wood := Color("6d4a32")
	var brass := Color("c49b4e")

	var left_x := feet.x - 7 + stride / 2
	var right_x := feet.x + 2 - stride / 2
	_rect(image, Rect2i(left_x, feet.y - 15, 7, 15), outline)
	_rect(image, Rect2i(right_x, feet.y - 15, 7, 15), outline)
	_rect(image, Rect2i(left_x + 1, feet.y - 13, 5, 10), robe_dark)
	_rect(image, Rect2i(right_x + 1, feet.y - 13, 5, 10), robe_mid)
	var torso := Vector2i(feet.x + dx * 2, feet.y - 40)
	_rect(image, Rect2i(torso.x - 17, torso.y - 15, 34, 37), outline)
	_rect(image, Rect2i(torso.x - 15, torso.y - 13, 30, 34), robe_dark)
	_rect(image, Rect2i(torso.x - 12, torso.y - 12, 13, 32), robe_mid)
	_rect(image, Rect2i(torso.x - 9, torso.y - 10, 5, 26), robe_light)
	_rect(image, Rect2i(torso.x - 16, torso.y + 14, 33, 8), outline)
	_rect(image, Rect2i(torso.x - 13, torso.y + 14, 27, 6), robe_mid)
	_rect(image, Rect2i(torso.x - 2, torso.y - 11, 5, 30), trim)
	_rect(image, Rect2i(torso.x - 1, torso.y - 8, 3, 3), brass)
	var sway: int = [1, -2, -1, 2][phase]
	_rect(image, Rect2i(torso.x - 21, torso.y - 8 + sway, 8, 24), outline)
	_rect(image, Rect2i(torso.x - 19, torso.y - 6 + sway, 5, 18), robe_mid)
	_rect(image, Rect2i(torso.x + 13, torso.y - 8 - sway, 8, 24), outline)
	_rect(image, Rect2i(torso.x + 14, torso.y - 6 - sway, 5, 18), robe_dark)
	var head := Vector2i(torso.x + dx * 3, torso.y - 25 + dy * 3)
	_rect(image, Rect2i(head.x - 10, head.y - 11, 20, 22), outline)
	_rect(image, Rect2i(head.x - 8, head.y - 9, 16, 18), skin_dark)
	_rect(image, Rect2i(head.x - 7, head.y - 8, 12, 15), skin)
	_rect(image, Rect2i(head.x - 5, head.y - 7, 6, 4), skin_light)
	_rect(image, Rect2i(head.x - 10, head.y - 11, 20, 6), hair_dark)
	_rect(image, Rect2i(head.x - 8, head.y - 10, 13, 3), hair)
	if dy >= 0:
		_rect(image, Rect2i(head.x - 5 + dx * 2, head.y, 3, 2), outline)
		_rect(image, Rect2i(head.x + 3 + dx * 2, head.y, 3, 2), outline)
		_rect(image, Rect2i(head.x - 5, head.y + 5, 12, 8), hair)
		_rect(image, Rect2i(head.x - 2, head.y + 5, 5, 7), hair_dark)
	else:
		_rect(image, Rect2i(head.x - 8, head.y - 3, 16, 8), hair)
	var staff_x := torso.x - 24
	_line(image, Vector2i(staff_x, torso.y - 18), Vector2i(staff_x + dx * 2, feet.y), wood)
	_rect(image, Rect2i(staff_x - 3, torso.y - 22, 7, 7), brass)
	_rect(image, Rect2i(staff_x - 1, torso.y - 20, 3, 3), outline)


func _generate_shadow() -> void:
	var image := Image.create(40, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var dark := Color("30312d")
	dark.a = 0.62
	_rect(image, Rect2i(8, 5, 22, 7), dark)
	_rect(image, Rect2i(4, 7, 32, 3), dark)
	_rect(image, Rect2i(12, 3, 14, 11), dark)
	_rect(image, Rect2i(28, 8, 10, 3), dark)
	image.save_png("res://art/characters/common/contact_shadow_40x16.png")


func _rect(image: Image, rect: Rect2i, color: Color) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
				image.set_pixel(x, y, color)


func _line(image: Image, from: Vector2i, to: Vector2i, color: Color) -> void:
	var delta := to - from
	var steps := maxi(abs(delta.x), abs(delta.y))
	for index in range(steps + 1):
		var point := (
			from
			+ Vector2i(
				roundi(float(delta.x * index) / steps), roundi(float(delta.y * index) / steps)
			)
		)
		_rect(image, Rect2i(point.x - 1, point.y, 3, 2), color)
