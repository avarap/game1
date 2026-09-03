class_name CemeteryCommercialComposition
extends Node

const TREE_TEXTURE := preload("res://art/environment/props/tree.png")
const DRY_GRASS_TEXTURE := preload("res://art/environment/cemetery/dry_grass.png")
const LEGACY_ATLAS_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/tileset_cemetery_32.png"
)

const TREE_PIVOT := Vector2(32, 84)
const DRY_GRASS_PIVOT := Vector2(16, 28)
const GRAVE_PIVOT := Vector2(16, 32)
const FENCE_PIVOT := Vector2(16, 32)
const PATH_EDGE_COLOR := Color8(67, 47, 31, 194)
const PATH_FILL_COLOR := Color8(112, 81, 49, 218)
const FENCE_TILE := Vector2i(4, 3)
const GRAVE_POSITIONS: Array[Vector2] = [
	Vector2(1061, 232),
	Vector2(1144, 204),
	Vector2(1247, 238),
	Vector2(1018, 319),
	Vector2(1110, 301),
	Vector2(1202, 337),
	Vector2(1310, 307),
	Vector2(1072, 406),
	Vector2(1178, 438),
	Vector2(1289, 401),
	Vector2(1108, 510),
	Vector2(1219, 487),
	Vector2(1302, 522),
]
const INNER_WALK_POINTS: Array[Vector2] = [
	Vector2(1008, 573),
	Vector2(1031, 548),
	Vector2(1058, 525),
	Vector2(1090, 508),
	Vector2(1127, 491),
	Vector2(1161, 467),
	Vector2(1188, 438),
	Vector2(1205, 403),
	Vector2(1211, 367),
	Vector2(1205, 332),
	Vector2(1189, 303),
	Vector2(1163, 280),
	Vector2(1128, 264),
	Vector2(1091, 258),
]
const LOW_CLUSTER_POSITIONS: Array[Vector2] = [
	Vector2(1028, 264),
	Vector2(1092, 248),
	Vector2(1160, 271),
	Vector2(1268, 266),
	Vector2(1001, 371),
	Vector2(1131, 394),
	Vector2(1230, 423),
	Vector2(1324, 388),
	Vector2(1041, 474),
	Vector2(1165, 523),
	Vector2(1280, 493),
]
const FRAME_TREE_POSITIONS: Array[Vector2] = [
	Vector2(972, 204),
	Vector2(1348, 230),
	Vector2(985, 612),
	Vector2(1375, 638),
]
const FOREGROUND_TREE_POSITIONS: Array[Vector2] = [
	Vector2(1082, 690),
	Vector2(1428, 704),
]
const FENCE_ANCHOR_CELLS: Array[Vector2i] = [
	Vector2i(31, 5),
	Vector2i(32, 5),
	Vector2i(36, 5),
	Vector2i(37, 5),
	Vector2i(42, 5),
	Vector2i(30, 8),
	Vector2i(30, 9),
	Vector2i(30, 13),
	Vector2i(30, 18),
	Vector2i(43, 6),
	Vector2i(43, 9),
	Vector2i(43, 10),
	Vector2i(43, 16),
	Vector2i(43, 17),
	Vector2i(32, 19),
	Vector2i(33, 19),
	Vector2i(36, 19),
	Vector2i(40, 19),
	Vector2i(42, 19),
	Vector2i(43, 19),
]
const RELOCATED_GRAVE_CELLS: Array[Vector2i] = [
	Vector2i(32, 7),
	Vector2i(37, 7),
	Vector2i(41, 7),
	Vector2i(32, 15),
	Vector2i(37, 15),
	Vector2i(41, 15),
]
const FENCE_CLUSTER_POSITIONS: Array[Vector2] = [
	Vector2(1008, 184),
	Vector2(1072, 171),
	Vector2(1335, 197),
	Vector2(970, 348),
	Vector2(1374, 382),
	Vector2(1084, 613),
	Vector2(1341, 621),
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
	_reauthor_enclosure(objects)
	_add_inner_walk(map)
	_recompose_graves(objects)
	_recompose_landmark(objects)
	_add_asymmetric_clusters(objects, low, foreground)


func _soften_cemetery_grid(paths: TileMapLayer) -> void:
	paths.modulate.a = 0.08


func _reauthor_enclosure(objects: TileMapLayer) -> void:
	for cell: Vector2i in objects.get_used_cells():
		if objects.get_cell_atlas_coords(cell) != FENCE_TILE:
			continue
		if cell not in FENCE_ANCHOR_CELLS:
			objects.erase_cell(cell)
	for cell: Vector2i in RELOCATED_GRAVE_CELLS:
		objects.erase_cell(cell)
	if objects.get_node_or_null("CommercialFenceCluster00") != null:
		return
	for index: int in range(FENCE_CLUSTER_POSITIONS.size()):
		_add_atlas_sprite(
			objects,
			FENCE_TILE,
			FENCE_CLUSTER_POSITIONS[index],
			"CommercialFenceCluster%02d" % index,
			FENCE_PIVOT,
		)


func _add_inner_walk(map: Node) -> void:
	if map.get_node_or_null("CemeteryInnerWalk") != null:
		return
	var walk := Node2D.new()
	walk.name = "CemeteryInnerWalk"
	walk.z_index = -9
	map.add_child(walk)
	_add_path_line(walk, "Edge", 35.0, PATH_EDGE_COLOR)
	_add_path_line(walk, "Fill", 21.0, PATH_FILL_COLOR)


func _add_path_line(parent: Node2D, suffix: String, width: float, color: Color) -> void:
	var line := Line2D.new()
	line.name = "InnerWalk%s" % suffix
	line.points = PackedVector2Array(INNER_WALK_POINTS)
	line.width = width
	line.default_color = color
	line.antialiased = false
	parent.add_child(line)


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
	_set_ground_position(landmark, "GateTreeLeft", Vector2(1178, 558), TREE_PIVOT)
	_set_ground_position(landmark, "GateTreeRight", Vector2(1318, 566), TREE_PIVOT)
	_set_ground_position(landmark, "MemorialLeft", Vector2(1215, 540), GRAVE_PIVOT)
	_set_ground_position(landmark, "MemorialCenter", Vector2(1248, 508), GRAVE_PIVOT)
	_set_ground_position(landmark, "MemorialRight", Vector2(1281, 542), GRAVE_PIVOT)
	_set_ground_position(landmark, "CemeteryGateSign", Vector2(1248, 578), GRAVE_PIVOT)


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
	_add_memorial_cluster(objects)


func _add_memorial_cluster(objects: TileMapLayer) -> void:
	if objects.get_node_or_null("CommercialMemorialCluster") != null:
		return
	var cluster := Node2D.new()
	cluster.name = "CommercialMemorialCluster"
	cluster.y_sort_enabled = true
	objects.add_child(cluster)
	_add_atlas_sprite(cluster, Vector2i(2, 3), Vector2(1187, 284), "MemorialWest")
	_add_atlas_sprite(cluster, Vector2i(1, 3), Vector2(1222, 268), "MemorialHeart")
	_add_atlas_sprite(cluster, Vector2i(3, 3), Vector2(1254, 291), "MemorialEast")


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
