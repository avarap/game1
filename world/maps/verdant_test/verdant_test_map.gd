extends Node2D
## Standalone visual experiment. Never registered with ZoneManager or save providers.

const CELL_SIZE := 32
const MAP_SIZE := Vector2i(30, 20)
const LOCAL_ASSET_DIRECTORY := "res://art/third_party/verdant_00"
const FALLBACK_ATLAS := preload("res://art/environment/tilesets/exterior_tileset.svg")
const FALLBACK_TREE := preload("res://art/environment/props/tree.svg")
const FALLBACK_ROCK := preload("res://art/environment/props/rock.svg")
const WORKSHOP := preload("res://art/environment/buildings/player_workshop.svg")
const RESOURCE_TREE := preload("res://world/resources/tree_resource.tscn")
const NEIGHBORS := [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

@export_dir var asset_directory: String = LOCAL_ASSET_DIRECTORY
@export var use_local_assets := true

var uses_verdant_assets := false
var _local_images: Dictionary = {}
var _path_cells: Dictionary = {}

@onready var ground: TileMapLayer = $Ground
@onready var paths: TileMapLayer = $Paths
@onready var objects: Node2D = $Objects
@onready var player: PlayerController = $Objects/Player


func _ready() -> void:
	uses_verdant_assets = _local_image("grass_0", Vector2i(16, 16)) != null
	_build_paths()
	_build_terrain()
	_build_objects()
	_build_boundary()
	player.position = $PlayerSpawn.position
	var camera := player.get_node("Camera2D") as Camera2D
	camera.limit_right = MAP_SIZE.x * CELL_SIZE
	camera.limit_bottom = MAP_SIZE.y * CELL_SIZE
	camera.reset_smoothing()
	var energy := player.get_energy_component()
	energy.energy_changed.connect($UI/StatusHud.set_energy)
	$UI/StatusHud.set_energy(energy.current_energy, energy.max_energy)
	$UI/Mode.text = (
		"VERDANT 00 · LOCAL PNGs" if uses_verdant_assets else "VERDANT TEST · FALLBACK"
	)


func _local_image(role: String, expected_size: Vector2i) -> Image:
	if not use_local_assets:
		return null
	if _local_images.has(role):
		return _local_images[role] as Image
	_local_images[role] = null
	var path := asset_directory.path_join(role + ".png")
	if not FileAccess.file_exists(path):
		return null
	var bytes := FileAccess.get_file_as_bytes(path)
	# Do not ask ResourceLoader to resolve an optional import or a missing dependency.
	if bytes.size() < 24 or bytes.slice(0, 8) != PackedByteArray([137, 80, 78, 71, 13, 10, 26, 10]):
		return null
	var image := Image.new()
	if image.load_png_from_buffer(bytes) != OK or image.get_size() != expected_size:
		return null
	image.convert(Image.FORMAT_RGBA8)
	_local_images[role] = image
	return image


func _fill_image(material: String, variant: int) -> Image:
	if uses_verdant_assets:
		var local := _local_image("%s_%d" % [material, variant], Vector2i(16, 16))
		if local == null:
			local = _local_image(material + "_0", Vector2i(16, 16))
		if local != null:
			var enlarged := local.duplicate() as Image
			enlarged.resize(CELL_SIZE, CELL_SIZE, Image.INTERPOLATE_NEAREST)
			return enlarged
	var column := variant + (4 if material == "dirt" else 0)
	return FALLBACK_ATLAS.get_image().get_region(Rect2i(column * CELL_SIZE, 0, 32, 32))


func _build_paths() -> void:
	# A three-cell lane, a workshop approach, and two wider clearings.
	for x in range(1, 29):
		var center_y := 11 if x < 21 else 12
		for y in range(center_y - 1, center_y + 2):
			_path_cells[Vector2i(x, y)] = true
	for rect in [Rect2i(18, 8, 3, 4), Rect2i(5, 9, 4, 5), Rect2i(23, 10, 4, 5)]:
		for y in range(rect.position.y, rect.end.y):
			for x in range(rect.position.x, rect.end.x):
				_path_cells[Vector2i(x, y)] = true


func _build_terrain() -> void:
	var atlas := Image.create(64 * CELL_SIZE, 2 * CELL_SIZE, false, Image.FORMAT_RGBA8)
	for variant in range(4):
		var grass := _fill_image("grass", variant)
		var dirt := _fill_image("dirt", variant)
		atlas.blit_rect(grass, Rect2i(0, 0, 32, 32), Vector2i(variant * 32, 0))
		for mask in range(16):
			var path_tile := _path_image(dirt, mask)
			atlas.blit_rect(
				path_tile, Rect2i(0, 0, 32, 32), Vector2i((mask * 4 + variant) * 32, 32)
			)
	var source := TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(atlas)
	source.texture_region_size = Vector2i(CELL_SIZE, CELL_SIZE)
	for column in range(64):
		source.create_tile(Vector2i(column, 1))
		if column < 4:
			source.create_tile(Vector2i(column, 0))
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(CELL_SIZE, CELL_SIZE)
	tile_set.add_source(source, 0)
	ground.tile_set = tile_set
	paths.tile_set = tile_set
	for y in range(MAP_SIZE.y):
		for x in range(MAP_SIZE.x):
			var cell := Vector2i(x, y)
			var variant := (x * 7 + y * 11 + x * y) % 4
			ground.set_cell(cell, 0, Vector2i(variant, 0))
			if _path_cells.has(cell):
				var mask := 0
				for index in range(4):
					if _path_cells.has(cell + NEIGHBORS[index]):
						mask |= 1 << index
				paths.set_cell(cell, 0, Vector2i(mask * 4 + variant, 1))


func _path_image(dirt: Image, mask: int) -> Image:
	var image := dirt.duplicate() as Image
	# Clip exposed edges only; connected cells have no seams. Two-pixel clusters
	# preserve the source grid. This does not claim to implement the pack's 47 masks.
	for y in range(CELL_SIZE):
		for x in range(CELL_SIZE):
			var edge_x := 2 + 2 * ((y / 4) % 2)
			var edge_y := 2 + 2 * ((x / 4) % 2)
			if (
				(mask & 1 == 0 and y < edge_y)
				or (mask & 2 == 0 and x >= CELL_SIZE - edge_x)
				or (mask & 4 == 0 and y >= CELL_SIZE - edge_y)
				or (mask & 8 == 0 and x < edge_x)
			):
				image.set_pixel(x, y, Color.TRANSPARENT)
	return image


func _build_objects() -> void:
	var trees: Array[Vector2i] = [Vector2i(4, 6), Vector2i(11, 6), Vector2i(25, 7)]
	for x in range(2, 29, 2):
		trees.append(Vector2i(x, 2 + x % 3))
		trees.append(Vector2i(x, 16 + (x / 2) % 3))
	for index in range(trees.size()):
		var tree := _obstacle("Tree%d" % index, _cell_center(trees[index]), Vector2(18, 16))
		_add_prop(tree, "tree", FALLBACK_TREE, Vector2(32, 84), Vector2i(32, 32))
	var rocks := [Vector2i(13, 8), Vector2i(27, 8), Vector2i(3, 15), Vector2i(21, 16)]
	for index in range(rocks.size()):
		var rock := _obstacle("Rock%d" % index, _cell_center(rocks[index]), Vector2(24, 16))
		_add_prop(rock, "rock", FALLBACK_ROCK, Vector2(24, 34), Vector2i(16, 16))
	var workshop := _obstacle("Workshop", Vector2(624, 272), Vector2(272, 128))
	var building := Sprite2D.new()
	building.texture = WORKSHOP
	building.centered = false
	building.position = -Vector2(192, 248)
	workshop.add_child(building)
	_build_harvest_tree()
	_build_decoration()


func _obstacle(node_name: String, foot: Vector2, footprint: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = node_name
	body.position = foot
	body.collision_layer = 1
	body.collision_mask = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = footprint
	collision.shape = shape
	collision.position.y = -footprint.y * 0.5
	body.add_child(collision)
	objects.add_child(body)
	return body


func _add_prop(
	parent: Node2D, role: String, fallback: Texture2D, pivot: Vector2, source_size: Vector2i
) -> void:
	var sprite := Sprite2D.new()
	sprite.name = "Art"
	sprite.centered = false
	var local: Image = _local_image(role, source_size) if uses_verdant_assets else null
	if local != null:
		sprite.texture = ImageTexture.create_from_image(local)
		sprite.scale = Vector2(2, 2)
		sprite.position = -Vector2(source_size.x, (source_size.y - 2) * 2)
	else:
		sprite.texture = fallback
		sprite.position = -pivot
	parent.add_child(sprite)


func _build_harvest_tree() -> void:
	var trunk := _obstacle("HarvestTree", Vector2(272, 272), Vector2(18, 16))
	_add_prop(trunk, "tree", FALLBACK_TREE, Vector2(32, 84), Vector2i(32, 32))
	var resource := RESOURCE_TREE.instantiate() as ResourceNode
	resource.name = "Resource"
	resource.get_node("Trunk").hide()
	resource.get_node("Crown").hide()
	trunk.add_child(resource)


func _build_decoration() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 730021
	for index in range(110):
		var cell := Vector2i(rng.randi_range(1, 28), rng.randi_range(4, 18))
		if _path_cells.has(cell) or Rect2i(14, 3, 10, 6).has_point(cell):
			continue
		var anchor := Node2D.new()
		anchor.position = _cell_center(cell) + Vector2(rng.randi_range(-8, 8), 4)
		$DecorationLow.add_child(anchor)
		var texture := AtlasTexture.new()
		texture.atlas = FALLBACK_ATLAS
		texture.region = Rect2((index % 2) * 32, 6 * 32, 32, 32)
		_add_prop(
			anchor,
			"flowers" if index % 3 == 0 else "bush",
			texture,
			Vector2(16, 24),
			Vector2i(16, 16)
		)


func _build_boundary() -> void:
	for rect in [
		Rect2(-32, -32, 1024, 32),
		Rect2(-32, 640, 1024, 32),
		Rect2(-32, 0, 32, 640),
		Rect2(960, 0, 32, 640),
	]:
		var body := StaticBody2D.new()
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		collision.shape = shape
		body.position = rect.get_center()
		body.add_child(collision)
		$Boundary.add_child(body)


func _cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell * CELL_SIZE) + Vector2(16, 16)
