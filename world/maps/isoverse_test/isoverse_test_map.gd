class_name IsoverseTestMap
extends Node2D

const MAP_SIZE := Vector2i(30, 20)
const TILE_HALF := Vector2(16, 8)
const MAP_ORIGIN := Vector2(480, 96)
const ATLAS_PATH := (
	"res://art/external/isoverse_medieval_outdoors/assets_free_version.png"
)

const TREE_REGION := Rect2i(96, 65, 32, 76)
const ROCK_REGION := Rect2i(131, 68, 25, 25)
const BUILDING_WEST_REGION := Rect2i(199, 1, 130, 127)
const BUILDING_EAST_REGION := Rect2i(343, 1, 130, 127)
const GRASS_REGION := Rect2i(0, 0, 32, 32)
const DIRT_REGION := Rect2i(32, 0, 32, 32)
const PATH_REGION := Rect2i(64, 32, 32, 32)

@onready var ground: Node2D = $Ground
@onready var paths: Node2D = $Paths
@onready var objects: Node2D = $Objects
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var player: CharacterBody2D = $Player

var _external_art_available := false


func _ready() -> void:
	_external_art_available = FileAccess.file_exists(ATLAS_PATH)
	if _external_art_available:
		_build_isoverse_map()
	else:
		_build_fallback_map()
	_build_collisions()
	player.global_position = player_spawn.global_position


func get_map_size() -> Vector2i:
	return MAP_SIZE


func uses_external_art() -> bool:
	return _external_art_available


func get_atlas_region(asset_name: String) -> Rect2i:
	match asset_name:
		"tree":
			return TREE_REGION
		"rock":
			return ROCK_REGION
		"building_west":
			return BUILDING_WEST_REGION
		"building_east":
			return BUILDING_EAST_REGION
		_:
			return Rect2i()


func _build_isoverse_map() -> void:
	var atlas := load(ATLAS_PATH) as Texture2D
	if atlas == null:
		_build_fallback_map()
		_external_art_available = false
		return

	for y in range(MAP_SIZE.y):
		for x in range(MAP_SIZE.x):
			var cell := Vector2i(x, y)
			var region := GRASS_REGION
			if (x + y) % 7 == 0:
				region = DIRT_REGION
			_add_atlas_sprite(ground, atlas, region, _cell_to_world(cell), Vector2(16, 8))

	for cell in _path_cells():
		_add_atlas_sprite(paths, atlas, PATH_REGION, _cell_to_world(cell), Vector2(16, 8))

	_add_atlas_sprite(
		objects,
		atlas,
		BUILDING_WEST_REGION,
		_cell_to_world(Vector2i(8, 3)),
		Vector2(65, 110),
	)
	_add_atlas_sprite(
		objects,
		atlas,
		BUILDING_EAST_REGION,
		_cell_to_world(Vector2i(20, 7)),
		Vector2(65, 110),
	)

	for cell in _tree_cells():
		_add_atlas_sprite(objects, atlas, TREE_REGION, _cell_to_world(cell), Vector2(16, 70))
	for cell in _rock_cells():
		_add_atlas_sprite(objects, atlas, ROCK_REGION, _cell_to_world(cell), Vector2(12, 21))


func _build_fallback_map() -> void:
	for y in range(MAP_SIZE.y):
		for x in range(MAP_SIZE.x):
			var cell := Vector2i(x, y)
			_add_fallback_diamond(ground, _cell_to_world(cell), Color("53664b"))

	for cell in _path_cells():
		_add_fallback_diamond(paths, _cell_to_world(cell), Color("78604a"))

	_add_fallback_building(_cell_to_world(Vector2i(8, 3)), Color("6a4b35"))
	_add_fallback_building(_cell_to_world(Vector2i(20, 7)), Color("76553c"))

	for cell in _tree_cells():
		_add_fallback_object(_cell_to_world(cell), Color("36533a"), Vector2(12, 34))
	for cell in _rock_cells():
		_add_fallback_object(_cell_to_world(cell), Color("5a5b55"), Vector2(10, 10))


func _path_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for x in range(3, 27):
		result.append(Vector2i(x, 10))
	for y in range(4, 16):
		result.append(Vector2i(15, y))
	for step in range(0, 8):
		result.append(Vector2i(8 + step, 3 + step))
	return result


func _tree_cells() -> Array[Vector2i]:
	return [
		Vector2i(2, 2),
		Vector2i(4, 4),
		Vector2i(2, 8),
		Vector2i(5, 16),
		Vector2i(9, 18),
		Vector2i(23, 2),
		Vector2i(26, 5),
		Vector2i(27, 12),
		Vector2i(24, 17),
		Vector2i(18, 18),
	]


func _rock_cells() -> Array[Vector2i]:
	return [
		Vector2i(6, 6),
		Vector2i(11, 15),
		Vector2i(22, 13),
		Vector2i(25, 8),
	]


func _cell_to_world(cell: Vector2i) -> Vector2:
	return MAP_ORIGIN + Vector2(
		(cell.x - cell.y) * TILE_HALF.x,
		(cell.x + cell.y) * TILE_HALF.y,
	)


func _add_atlas_sprite(
	parent: Node2D,
	atlas: Texture2D,
	region: Rect2i,
	position: Vector2,
	pivot: Vector2,
) -> void:
	var texture := AtlasTexture.new()
	texture.atlas = atlas
	texture.region = Rect2(region)
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.texture = texture
	sprite.position = position - pivot
	sprite.centered = false
	parent.add_child(sprite)


func _add_fallback_diamond(parent: Node2D, position: Vector2, color: Color) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array(
		[
			Vector2(0, -8),
			Vector2(16, 0),
			Vector2(0, 8),
			Vector2(-16, 0),
		]
	)
	polygon.color = color
	polygon.position = position
	parent.add_child(polygon)


func _add_fallback_building(position: Vector2, color: Color) -> void:
	_add_fallback_object(position - Vector2(0, 36), color, Vector2(52, 42))


func _add_fallback_object(position: Vector2, color: Color, half_size: Vector2) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array(
		[
			Vector2(-half_size.x, -half_size.y),
			Vector2(half_size.x, -half_size.y),
			Vector2(half_size.x, half_size.y),
			Vector2(-half_size.x, half_size.y),
		]
	)
	polygon.color = color
	polygon.position = position - Vector2(0, half_size.y)
	objects.add_child(polygon)


func _build_collisions() -> void:
	_add_rect_collision(_cell_to_world(Vector2i(8, 3)), Vector2(94, 58))
	_add_rect_collision(_cell_to_world(Vector2i(20, 7)), Vector2(94, 58))
	for cell in _tree_cells():
		_add_rect_collision(_cell_to_world(cell), Vector2(12, 12))
	for cell in _rock_cells():
		_add_rect_collision(_cell_to_world(cell), Vector2(16, 12))


func _add_rect_collision(position: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = position
	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)
	$Collisions.add_child(body)
