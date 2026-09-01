extends RefCounted
## Continuous world-space edges avoid repeating a square path mask per tile.

const MAP_SIZE := Vector2i(30, 20)
const NATIVE_SIZE := Vector2i(480, 320)
static var _distances := PackedFloat32Array()


static func populate(
	ground: TileMapLayer, paths: TileMapLayer, grass: Array[Image], dirt: Array[Image]
) -> void:
	_ensure_distances()
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(32, 32)
	var grass_image := Image.create(128, 32, false, Image.FORMAT_RGBA8)
	for variant in range(4):
		grass_image.blit_rect(grass[variant], Rect2i(0, 0, 32, 32), Vector2i(variant * 32, 0))
	var base := TileSetAtlasSource.new()
	base.texture = ImageTexture.create_from_image(grass_image)
	base.texture_region_size = Vector2i(32, 32)
	for variant in range(4):
		base.create_tile(Vector2i(variant, 0))
	tile_set.add_source(base, 0)
	var path_image := Image.create(960, 640, false, Image.FORMAT_RGBA8)
	var source := TileSetAtlasSource.new()
	source.texture_region_size = Vector2i(32, 32)
	var path_cells: Array[Vector2i] = []
	var noise := FastNoiseLite.new()
	noise.seed = 730021
	noise.frequency = 0.035
	ground.tile_set = tile_set
	for y in range(MAP_SIZE.y):
		for x in range(MAP_SIZE.x):
			var cell := Vector2i(x, y)
			var variant := clampi(int((noise.get_noise_2d(x * 16, y * 16) + 0.7) * 3), 0, 3)
			ground.set_cell(cell, 0, Vector2i(variant, 0))
			var tile := _path_tile(cell, dirt[(x * 13 + y * 7) % 4])
			if not tile.is_invisible():
				path_image.blit_rect(tile, Rect2i(0, 0, 32, 32), cell * 32)
				path_cells.append(cell)
	source.texture = ImageTexture.create_from_image(path_image)
	for cell in path_cells:
		source.create_tile(cell)
	tile_set.add_source(source, 1)
	paths.tile_set = tile_set
	for cell in path_cells:
		paths.set_cell(cell, 1, cell)


static func _path_tile(cell: Vector2i, dirt: Image) -> Image:
	var tile := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	for y in range(16):
		for x in range(16):
			var sample := cell * 16 + Vector2i(x, y)
			var distance := _distances[sample.y * NATIVE_SIZE.x + sample.x]
			if distance > 0:
				continue
			var color := dirt.get_pixel(x * 2, y * 2)
			if distance > -3:
				color = color.darkened(0.14)
			tile.fill_rect(Rect2i(x * 2, y * 2, 2, 2), color)
	return tile


static func _ensure_distances() -> void:
	if not _distances.is_empty():
		return
	_distances.resize(NATIVE_SIZE.x * NATIVE_SIZE.y)
	for y in range(NATIVE_SIZE.y):
		for x in range(NATIVE_SIZE.x):
			var point := Vector2(x * 2 + 1, y * 2 + 1)
			var center_y := 366 + sin(point.x / 140.0) * 9 + maxf(0, point.x - 570) * 0.085
			var lane := absf(point.y - center_y) - 36 - sin(point.x / 70.0) * 3
			# Approach matches the workshop's door, not its visual center.
			var approach := point.distance_to(Vector2(684, clampf(point.y, 276, 386))) - 31
			var west := ((point - Vector2(240, 370)) / Vector2(75, 52)).length() * 52 - 52
			var east := ((point - Vector2(816, 398)) / Vector2(66, 49)).length() * 49 - 49
			var distance := minf(minf(lane, approach), minf(west, east))
			# Two-pixel boundary clusters, evaluated globally so adjacent tiles meet.
			distance += sin(point.x * 0.17) * sin(point.y * 0.13) * 2.0
			_distances[y * NATIVE_SIZE.x + x] = distance
