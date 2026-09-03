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
const PATH_EDGE_COLOR := Color8(67, 47, 31, 194)
const PATH_FILL_COLOR := Color8(112, 81, 49, 218)
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
	Vector2(1010, 568),
	Vector2(1038, 527),
	Vector2(1054, 480),
	Vector2(1047, 432),
	Vector2(1064, 382),
	Vector2(1101, 349),
	Vector2(1148, 336),
	Vector2(1198, 345),
	Vector2(1241, 370),
	Vector2(1274, 410),
	Vector2(1283, 454),
	Vector2(1266, 500),
	Vector2(1235, 535),
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


func _ready() -> void:
	var map := get_parent()
	if map == null:
		return
	map.ready.connect(_apply_composition.bind(map), CONNECT_ONE_SHOT)


func _apply_composition(map: Node) -> void:
	var paths := map.get_node_or_null("paths") as TileMapLayer
	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	var low := map.get_node_or_null("decoration_low") as TileMapLayer
	if paths == null or objects == null or low == null:
		return

	_reduce_cemetery_grid(paths)
	_add_inner_walk(map)
	_recompose_graves(objects)
	_recompose_landmark(objects)
	_add_asymmetric_clusters(objects, low)


func _reduce_cemetery_grid(paths: TileMapLayer) -> void:
	for cell: Vector2i in paths.get_used_cells():
		if cell.x >= 31 and cell.x <= 43 and cell.y >= 7 and cell.y <= 18:
			paths.erase_cell(cell)
	paths.modulate.a = 0.11


func _add_inner_walk(map: Node) -> void:
	if map.get_node_or_null("CemeteryInnerWalk") != null:
		return
	var walk := Node2D.new()
	walk.name = "CemeteryInnerWalk"
	walk.z_index = -9
	map.add_child(walk)
	_add_path_line(walk, "Edge", 43.0, PATH_EDGE_COLOR)
	_add_path_line(walk, "Fill", 27.0, PATH_FILL_COLOR)


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
	_set_ground_position(landmark, "GateTreeLeft", Vector2(1148, 554), TREE_PIVOT)
	_set_ground_position(landmark, "GateTreeRight", Vector2(1336, 563), TREE_PIVOT)
	_set_ground_position(landmark, "MemorialLeft", Vector2(1203, 540), GRAVE_PIVOT)
	_set_ground_position(landmark, "MemorialCenter", Vector2(1249, 512), GRAVE_PIVOT)
	_set_ground_position(landmark, "MemorialRight", Vector2(1294, 543), GRAVE_PIVOT)
	_set_ground_position(landmark, "CemeteryGateSign", Vector2(1248, 574), GRAVE_PIVOT)


func _set_ground_position(
	parent: Node2D,
	child_name: String,
	ground_position: Vector2,
	pivot: Vector2,
) -> void:
	var child := parent.get_node_or_null(child_name) as Sprite2D
	if child != null:
		child.position = ground_position - pivot


func _add_asymmetric_clusters(objects: TileMapLayer, low: TileMapLayer) -> void:
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
) -> void:
	var texture := AtlasTexture.new()
	texture.atlas = LEGACY_ATLAS_TEXTURE
	texture.region = Rect2(atlas_cell * 32, Vector2i(32, 32))
	_add_sprite(parent, texture, ground_position, GRAVE_PIVOT, sprite_name)


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
