class_name CemeteryCommercialComposition
extends Node

const TREE_TEXTURE := preload("res://art/environment/props/tree.png")
const DRY_GRASS_TEXTURE := preload("res://art/environment/cemetery/dry_grass.png")
const TERRAIN_ATLAS_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/terrain_ground_paths_32.png"
)
const LEGACY_ATLAS_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/tileset_cemetery_32.png"
)

const TREE_PIVOT := Vector2(32, 84)
const DRY_GRASS_PIVOT := Vector2(16, 28)
const GRAVE_PIVOT := Vector2(16, 32)
const TERRAIN_PIVOT := Vector2(16, 16)
const PATH_EDGE_COLOR := Color8(67, 47, 31, 184)
const PATH_FILL_COLOR := Color8(112, 81, 49, 210)
const CEMETERY_VISUAL_RECT := Rect2i(Vector2i(30, 5), Vector2i(14, 15))
const GRAVE_POSITIONS: Array[Vector2] = [
	Vector2(1034, 245),
	Vector2(1068, 230),
	Vector2(1109, 258),
	Vector2(1266, 236),
	Vector2(1304, 218),
	Vector2(1332, 258),
	Vector2(1289, 286),
	Vector2(1015, 354),
	Vector2(1051, 377),
	Vector2(1096, 349),
	Vector2(1299, 390),
	Vector2(1334, 418),
	Vector2(1260, 438),
]
const INNER_WALK_POINTS: Array[Vector2] = [
	Vector2(1007, 575),
	Vector2(1032, 554),
	Vector2(1054, 529),
	Vector2(1085, 512),
	Vector2(1117, 494),
	Vector2(1143, 463),
	Vector2(1169, 431),
	Vector2(1188, 397),
	Vector2(1197, 362),
	Vector2(1192, 329),
	Vector2(1177, 302),
	Vector2(1150, 280),
	Vector2(1116, 267),
]
const LOW_CLUSTER_POSITIONS: Array[Vector2] = [
	Vector2(1011, 272),
	Vector2(1052, 207),
	Vector2(1119, 286),
	Vector2(1260, 202),
	Vector2(1321, 295),
	Vector2(985, 333),
	Vector2(1074, 408),
	Vector2(1241, 416),
	Vector2(1345, 444),
	Vector2(1027, 493),
	Vector2(1161, 533),
	Vector2(1310, 507),
]
const FRAME_TREE_POSITIONS: Array[Vector2] = [
	Vector2(968, 210),
	Vector2(1352, 239),
	Vector2(1381, 624),
]
const FOREGROUND_TREE_POSITIONS: Array[Vector2] = [
	Vector2(1037, 677),
	Vector2(1378, 664),
	Vector2(1458, 724),
]
const FOREGROUND_GRASS_POSITIONS: Array[Vector2] = [
	Vector2(1118, 676),
	Vector2(1284, 688),
	Vector2(1340, 651),
	Vector2(1492, 697),
]
const EDGE_GROUND_POSITIONS: Array[Vector2] = [
	Vector2(1017, 559),
	Vector2(1042, 536),
	Vector2(1074, 503),
	Vector2(1122, 478),
	Vector2(1149, 441),
	Vector2(1178, 408),
	Vector2(1210, 372),
	Vector2(1170, 337),
	Vector2(1204, 311),
	Vector2(1141, 294),
]
const EDGE_GROUND_TILES: Array[Vector2i] = [
	Vector2i(6, 0),
	Vector2i(2, 0),
	Vector2i(7, 0),
	Vector2i(3, 0),
	Vector2i(5, 0),
	Vector2i(1, 0),
	Vector2i(6, 0),
	Vector2i(4, 0),
	Vector2i(2, 0),
	Vector2i(7, 0),
]
const EDGE_PATH_POSITIONS: Array[Vector2] = [
	Vector2(1029, 571),
	Vector2(1065, 520),
	Vector2(1101, 500),
	Vector2(1134, 468),
	Vector2(1160, 422),
	Vector2(1201, 392),
	Vector2(1178, 349),
	Vector2(1205, 323),
	Vector2(1161, 289),
]
const EDGE_PATH_TILES: Array[Vector2i] = [
	Vector2i(7, 1),
	Vector2i(3, 1),
	Vector2i(5, 1),
	Vector2i(1, 1),
	Vector2i(6, 1),
	Vector2i(2, 1),
	Vector2i(4, 1),
	Vector2i(7, 1),
	Vector2i(3, 1),
]


func _ready() -> void:
	var map := get_parent()
	if map == null:
		return
	map.ready.connect(_apply_composition.bind(map), CONNECT_ONE_SHOT)


func _apply_composition(map: Node) -> void:
	var paths := map.get_node_or_null("paths") as TileMapLayer
	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	var low := map.get_node_or_null("decoration_low") as TileMapLayer
	var foreground := map.get_node_or_null("foreground_occlusion") as TileMapLayer
	if paths == null or objects == null or low == null or foreground == null:
		return

	_soften_cemetery_grid(paths)
	_remove_technical_enclosure(objects)
	_add_inner_walk(map)
	_add_path_transitions(low)
	_recompose_graves(objects)
	_recompose_landmark(objects)
	_add_asymmetric_clusters(objects, low, foreground)


func _soften_cemetery_grid(paths: TileMapLayer) -> void:
	paths.modulate.a = 0.055


func _remove_technical_enclosure(objects: TileMapLayer) -> void:
	for cell: Vector2i in objects.get_used_cells():
		if CEMETERY_VISUAL_RECT.has_point(cell):
			objects.erase_cell(cell)


func _add_inner_walk(map: Node) -> void:
	if map.get_node_or_null("CemeteryInnerWalk") != null:
		return
	var walk := Node2D.new()
	walk.name = "CemeteryInnerWalk"
	walk.z_index = -9
	map.add_child(walk)
	_add_path_line(walk, "Edge", 27.0, PATH_EDGE_COLOR)
	_add_path_line(walk, "Fill", 15.0, PATH_FILL_COLOR)


func _add_path_line(parent: Node2D, suffix: String, width: float, color: Color) -> void:
	var line := Line2D.new()
	line.name = "InnerWalk%s" % suffix
	line.points = PackedVector2Array(INNER_WALK_POINTS)
	line.width = width
	line.width_curve = _inner_walk_width_profile()
	line.default_color = color
	line.antialiased = false
	parent.add_child(line)


func _inner_walk_width_profile() -> Curve:
	var profile := Curve.new()
	profile.min_value = 0.66
	profile.max_value = 1.16
	profile.add_point(Vector2(0.0, 0.76))
	profile.add_point(Vector2(0.17, 1.08))
	profile.add_point(Vector2(0.34, 0.71))
	profile.add_point(Vector2(0.53, 1.13))
	profile.add_point(Vector2(0.69, 0.79))
	profile.add_point(Vector2(0.86, 1.04))
	profile.add_point(Vector2(1.0, 0.72))
	return profile


func _add_path_transitions(low: TileMapLayer) -> void:
	if low.get_node_or_null("CommercialPathTransitions") != null:
		return
	var transitions := Node2D.new()
	transitions.name = "CommercialPathTransitions"
	low.add_child(transitions)
	for index: int in range(EDGE_GROUND_POSITIONS.size()):
		_add_terrain_atlas_sprite(
			transitions,
			EDGE_GROUND_TILES[index],
			EDGE_GROUND_POSITIONS[index],
			"GroundErosion%02d" % index,
			0.90,
		)
	for index: int in range(EDGE_PATH_POSITIONS.size()):
		_add_terrain_atlas_sprite(
			transitions,
			EDGE_PATH_TILES[index],
			EDGE_PATH_POSITIONS[index],
			"PathShoulder%02d" % index,
			0.74,
		)


func _recompose_graves(objects: TileMapLayer) -> void:
	for index: int in range(GRAVE_POSITIONS.size()):
		var grave := objects.get_node_or_null("GraveVisual%02d" % index) as Sprite2D
		if grave == null:
			continue
		grave.position = GRAVE_POSITIONS[index] - GRAVE_PIVOT
		grave.z_index = 0


func _recompose_landmark(objects: TileMapLayer) -> void:
	var landmark := objects.get_node_or_null("CemeteryLandmark") as Node2D
	if landmark == null:
		return
	_set_ground_position(landmark, "GateTreeLeft", Vector2(1171, 560), TREE_PIVOT)
	_set_ground_position(landmark, "GateTreeRight", Vector2(1327, 568), TREE_PIVOT)
	_set_ground_position(landmark, "MemorialLeft", Vector2(1214, 532), GRAVE_PIVOT)
	_set_ground_position(landmark, "MemorialCenter", Vector2(1249, 492), GRAVE_PIVOT)
	_set_ground_position(landmark, "MemorialRight", Vector2(1288, 535), GRAVE_PIVOT)
	_set_ground_position(landmark, "CemeteryGateSign", Vector2(1249, 574), GRAVE_PIVOT)


func _set_ground_position(
	parent: Node2D,
	child_name: String,
	ground_position: Vector2,
	pivot: Vector2,
) -> void:
	var child := parent.get_node_or_null(child_name) as Sprite2D
	if child != null:
		child.position = ground_position - pivot


func _add_asymmetric_clusters(
	objects: TileMapLayer,
	low: TileMapLayer,
	foreground: TileMapLayer,
) -> void:
	if low.get_node_or_null("CommercialLowCluster00") == null:
		for index: int in range(LOW_CLUSTER_POSITIONS.size()):
			_add_sprite(
				low,
				DRY_GRASS_TEXTURE,
				LOW_CLUSTER_POSITIONS[index],
				DRY_GRASS_PIVOT,
				"CommercialLowCluster%02d" % index,
			)
	if objects.get_node_or_null("CommercialFrameTree00") == null:
		for index: int in range(FRAME_TREE_POSITIONS.size()):
			_add_sprite(
				objects,
				TREE_TEXTURE,
				FRAME_TREE_POSITIONS[index],
				TREE_PIVOT,
				"CommercialFrameTree%02d" % index,
			)
	if foreground.get_node_or_null("CommercialForegroundTree00") == null:
		for index: int in range(FOREGROUND_TREE_POSITIONS.size()):
			_add_sprite(
				foreground,
				TREE_TEXTURE,
				FOREGROUND_TREE_POSITIONS[index],
				TREE_PIVOT,
				"CommercialForegroundTree%02d" % index,
			)
	if foreground.get_node_or_null("CommercialForegroundGrass00") == null:
		for index: int in range(FOREGROUND_GRASS_POSITIONS.size()):
			_add_sprite(
				foreground,
				DRY_GRASS_TEXTURE,
				FOREGROUND_GRASS_POSITIONS[index],
				DRY_GRASS_PIVOT,
				"CommercialForegroundGrass%02d" % index,
			)
	_add_memorial_cluster(objects)


func _add_memorial_cluster(objects: TileMapLayer) -> void:
	if objects.get_node_or_null("CommercialMemorialCluster") != null:
		return
	var cluster := Node2D.new()
	cluster.name = "CommercialMemorialCluster"
	cluster.y_sort_enabled = true
	objects.add_child(cluster)
	_add_sprite(cluster, TREE_TEXTURE, Vector2(1249, 462), TREE_PIVOT, "MemorialCanopy")
	_add_atlas_sprite(cluster, Vector2i(2, 3), Vector2(1206, 506), "MemorialWest")
	_add_atlas_sprite(cluster, Vector2i(1, 3), Vector2(1248, 470), "MemorialHeart")
	_add_atlas_sprite(cluster, Vector2i(3, 3), Vector2(1294, 511), "MemorialEast")


func _add_atlas_sprite(
	parent: Node2D,
	atlas_cell: Vector2i,
	ground_position: Vector2,
	sprite_name: String,
	pivot: Vector2 = GRAVE_PIVOT,
) -> void:
	var texture := AtlasTexture.new()
	texture.atlas = LEGACY_ATLAS_TEXTURE
	texture.region = Rect2(atlas_cell * 32, Vector2i(32, 32))
	_add_sprite(parent, texture, ground_position, pivot, sprite_name)


func _add_terrain_atlas_sprite(
	parent: Node2D,
	atlas_cell: Vector2i,
	ground_position: Vector2,
	sprite_name: String,
	alpha: float,
) -> void:
	var texture := AtlasTexture.new()
	texture.atlas = TERRAIN_ATLAS_TEXTURE
	texture.region = Rect2(atlas_cell * 32, Vector2i(32, 32))
	var sprite := Sprite2D.new()
	sprite.name = sprite_name
	sprite.texture = texture
	sprite.centered = false
	sprite.position = ground_position - TERRAIN_PIVOT
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.modulate.a = alpha
	parent.add_child(sprite)


func _add_sprite(
	parent: Node2D,
	texture: Texture2D,
	ground_position: Vector2,
	pivot: Vector2,
	sprite_name: String,
) -> void:
	var sprite := Sprite2D.new()
	sprite.name = sprite_name
	sprite.texture = texture
	sprite.centered = false
	sprite.position = ground_position - pivot
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(sprite)
