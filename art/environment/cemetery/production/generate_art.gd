extends SceneTree

const OUT := "res://art/environment/cemetery/production/atlas"
const INK := Color("24231f")
const SOIL_DARK := Color("4a3b32")
const SOIL := Color("715845")
const OCHRE := Color("a77b45")
const MOSS_DARK := Color("344536")
const MOSS := Color("566b45")
const GRASS := Color("75835a")
const BONE := Color("c9be9b")
const MIST := Color("8a9290")
const SHADOW := Color("30312d")
const RUST := Color("9a5140")
const LIGHT := Color("e0b66c")


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	_make_tiles()
	_make_workshop()
	quit()


func _rect(image: Image, rect: Rect2i, color: Color) -> void:
	image.fill_rect(rect, color)


func _px(image: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
		image.set_pixel(x, y, color)


func _tile_origin(index: Vector2i) -> Vector2i:
	return index * 32


func _make_tiles() -> void:
	var image := Image.create_empty(512, 512, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for x in range(8):
		_ground(image, Vector2i(x, 0), x)
	for x in range(8):
		_path(image, Vector2i(x, 1), x)
	for x in range(8):
		_decal(image, Vector2i(x, 2), x)
	for x in range(8):
		_object(image, Vector2i(x, 3), x)
	for x in range(8):
		_object(image, Vector2i(x, 4), x + 8)
	for x in range(8):
		_object(image, Vector2i(x, 5), x + 16)
	for x in range(8):
		_foreground(image, Vector2i(x, 6), x)
	image.save_png(OUT.path_join("tileset_cemetery_32.png"))


func _ground(image: Image, cell: Vector2i, variant: int) -> void:
	var o := _tile_origin(cell)
	_rect(image, Rect2i(o, Vector2i(32, 32)), MOSS)
	var seed := variant * 37 + 11
	for i in range(18):
		var x := (seed + i * 13) % 30 + 1
		var y := (seed * 3 + i * 17) % 30 + 1
		var color := GRASS if i % 3 == 0 else (SOIL_DARK if i % 4 == 0 else Color("45583e"))
		_px(image, o.x + x, o.y + y, color)
		if i % 5 == 0:
			_px(image, o.x + x + 1, o.y + y, color)
	if variant in [1, 4]:
		_rect(image, Rect2i(o + Vector2i(5, 18), Vector2i(8, 2)), SOIL_DARK)
	if variant in [2, 6]:
		_rect(image, Rect2i(o + Vector2i(21, 7), Vector2i(2, 6)), GRASS)


func _path(image: Image, cell: Vector2i, variant: int) -> void:
	var o := _tile_origin(cell)
	_rect(image, Rect2i(o, Vector2i(32, 32)), Color.TRANSPARENT)
	var width := 24 if variant % 3 else 28
	var left := (32 - width) / 2
	if variant < 4:
		_rect(image, Rect2i(o + Vector2i(left, 0), Vector2i(width, 32)), SOIL_DARK)
		_rect(image, Rect2i(o + Vector2i(left + 2, 0), Vector2i(width - 5, 32)), SOIL)
		for y in range(3, 32, 7):
			_px(image, o.x + left + 4 + (y + variant * 3) % max(5, width - 9), o.y + y, OCHRE)
	else:
		_rect(image, Rect2i(o + Vector2i(0, left), Vector2i(32, width)), SOIL_DARK)
		_rect(image, Rect2i(o + Vector2i(0, left + 2), Vector2i(32, width - 5)), SOIL)
		for x in range(3, 32, 7):
			_px(image, o.x + x, o.y + left + 4 + (x + variant) % max(5, width - 9), OCHRE)


func _decal(image: Image, cell: Vector2i, variant: int) -> void:
	var o := _tile_origin(cell)
	for i in range(3 + variant % 4):
		var x := 5 + (i * 7 + variant * 3) % 23
		var y := 7 + (i * 11 + variant * 5) % 20
		var color := GRASS if variant < 4 else (BONE if variant == 6 else OCHRE)
		_rect(image, Rect2i(o + Vector2i(x, y), Vector2i(2, 5 if variant < 4 else 2)), color)
		_px(image, o.x + x - 1, o.y + y + 2, color)


func _object(image: Image, cell: Vector2i, variant: int) -> void:
	var o := _tile_origin(cell)
	_rect(image, Rect2i(o + Vector2i(7, 25), Vector2i(21, 5)), SHADOW)
	match variant % 8:
		0, 1, 2:
			_rect(image, Rect2i(o + Vector2i(10, 9), Vector2i(14, 18)), INK)
			_rect(
				image,
				Rect2i(o + Vector2i(12, 7 + variant % 3), Vector2i(10, 18)),
				BONE if variant != 1 else MIST
			)
			_rect(image, Rect2i(o + Vector2i(13, 9), Vector2i(8, 2)), Color("ded3b2"))
			_rect(image, Rect2i(o + Vector2i(9, 24), Vector2i(16, 4)), SOIL_DARK)
		3:
			_rect(image, Rect2i(o + Vector2i(5, 19), Vector2i(24, 8)), SOIL_DARK)
			_rect(image, Rect2i(o + Vector2i(7, 16), Vector2i(20, 9)), SOIL)
			_rect(image, Rect2i(o + Vector2i(9, 15), Vector2i(16, 2)), OCHRE)
		4:
			_rect(image, Rect2i(o + Vector2i(5, 12), Vector2i(5, 16)), INK)
			_rect(image, Rect2i(o + Vector2i(22, 12), Vector2i(5, 16)), INK)
			_rect(image, Rect2i(o + Vector2i(8, 14), Vector2i(16, 3)), RUST)
		5:
			_rect(image, Rect2i(o + Vector2i(7, 17), Vector2i(20, 10)), SOIL_DARK)
			_rect(image, Rect2i(o + Vector2i(9, 15), Vector2i(16, 10)), OCHRE)
			_rect(image, Rect2i(o + Vector2i(11, 17), Vector2i(12, 4)), BONE)
		6:
			_rect(image, Rect2i(o + Vector2i(13, 8), Vector2i(7, 20)), SOIL_DARK)
			_rect(image, Rect2i(o + Vector2i(8, 9), Vector2i(18, 4)), SOIL)
			_rect(image, Rect2i(o + Vector2i(10, 8), Vector2i(13, 2)), OCHRE)
		7:
			_rect(image, Rect2i(o + Vector2i(6, 20), Vector2i(22, 7)), MOSS_DARK)
			_rect(image, Rect2i(o + Vector2i(9, 14), Vector2i(6, 12)), GRASS)
			_rect(image, Rect2i(o + Vector2i(16, 11), Vector2i(8, 15)), MOSS)


func _foreground(image: Image, cell: Vector2i, variant: int) -> void:
	var o := _tile_origin(cell)
	_rect(image, Rect2i(o + Vector2i(2, 4), Vector2i(28, 18)), INK)
	_rect(image, Rect2i(o + Vector2i(4, 2), Vector2i(24, 18)), MOSS_DARK)
	_rect(image, Rect2i(o + Vector2i(7, 4), Vector2i(10, 9)), MOSS)
	_rect(image, Rect2i(o + Vector2i(17, 7), Vector2i(9, 8)), GRASS if variant % 2 == 0 else MOSS)


func _make_workshop() -> void:
	var image := Image.create_empty(320, 256, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_rect(image, Rect2i(30, 225, 266, 15), SHADOW)
	_rect(image, Rect2i(45, 92, 230, 137), INK)
	_rect(image, Rect2i(51, 97, 218, 126), SOIL_DARK)
	_rect(image, Rect2i(65, 113, 102, 105), Color("827056"))
	_rect(image, Rect2i(176, 118, 72, 105), Color("49332a"))
	_rect(image, Rect2i(190, 151, 43, 72), INK)
	_rect(image, Rect2i(195, 156, 33, 67), SOIL)
	for x in range(199, 228, 7):
		_rect(image, Rect2i(x, 158, 3, 62), SOIL_DARK)
	_rect(image, Rect2i(78, 139, 58, 44), INK)
	_rect(image, Rect2i(83, 144, 48, 34), LIGHT)
	_rect(image, Rect2i(88, 150, 17, 22), OCHRE)
	_rect(image, Rect2i(110, 146, 17, 27), Color("f0c878"))
	_rect(image, Rect2i(21, 80, 279, 28), INK)
	_rect(image, Rect2i(32, 69, 250, 31), SOIL_DARK)
	_rect(image, Rect2i(52, 50, 214, 30), Color("5a4032"))
	_rect(image, Rect2i(78, 35, 165, 24), RUST)
	for x in range(43, 278, 28):
		_rect(image, Rect2i(x, 76 + (x / 28) % 4, 22, 5), OCHRE)
	_rect(image, Rect2i(44, 214, 225, 9), Color("6b6858"))
	_rect(image, Rect2i(65, 210, 38, 4), BONE)
	image.save_png(OUT.path_join("building_workshop_exterior.png"))
