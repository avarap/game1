class_name CemeteryCommercialFinish
extends Node

const TREE_TEXTURE := preload("res://art/environment/props/tree.png")
const DRY_GRASS_TEXTURE := preload("res://art/environment/cemetery/dry_grass.png")
const SIGN_TEXTURE := preload("res://art/environment/props/sign.png")
const TERRAIN_ATLAS_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/terrain_ground_paths_32.png"
)
const LEGACY_ATLAS_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/tileset_cemetery_32.png"
)

const TREE_PIVOT := Vector2(32, 84)
const DRY_GRASS_PIVOT := Vector2(16, 28)
const GRAVE_PIVOT := Vector2(16, 32)
const SIGN_PIVOT := Vector2(16, 32)
const TERRAIN_PIVOT := Vector2(16, 16)
const CEMETERY_VISUAL_RECT := Rect2i(Vector2i(30, 5), Vector2i(14, 15))
const TECHNICAL_LEGACY_CELLS: Array[Vector2i] = [
	Vector2i(0, 3),
	Vector2i(2, 3),
	Vector2i(3, 3),
	Vector2i(4, 3),
]

const GRAVE_FINISH_POSITIONS: Array[Vector2] = [
	Vector2(1016, 236),
	Vector2(1052, 214),
	Vector2(1102, 251),
	Vector2(1260, 223),
	Vector2(1307, 204),
	Vector2(1342, 251),
	Vector2(1277, 285),
	Vector2(1000, 352),
	Vector2(1044, 384),
	Vector2(1093, 345),
	Vector2(1307, 385),
	Vector2(1346, 430),
	Vector2(1248, 450),
]
const GRAVE_FLIPS: Array[bool] = [
	false,
	true,
	false,
	true,
	false,
	true,
	true,
	false,
	true,
	false,
	true,
	false,
	true,
]
const TRANSITION_POSITIONS: Array[Vector2] = [
	Vector2(1018, 568),
	Vector2(1044, 541),
	Vector2(1071, 520),
	Vector2(1106, 499),
	Vector2(1138, 472),
	Vector2(1162, 438),
	Vector2(1185, 409),
	Vector2(1204, 376),
	Vector2(1184, 345),
	Vector2(1197, 316),
	Vector2(1168, 292),
	Vector2(1129, 273),
]
const TRANSITION_TILES: Array[Vector2i] = [
	Vector2i(6, 0),
	Vector2i(1, 1),
	Vector2i(7, 0),
	Vector2i(4, 1),
	Vector2i(2, 0),
	Vector2i(6, 1),
	Vector2i(5, 0),
	Vector2i(2, 1),
	Vector2i(7, 1),
	Vector2i(3, 0),
	Vector2i(5, 1),
	Vector2i(1, 0),
]
const TRANSITION_FLIPS: Array[bool] = [
	false,
	true,
	true,
	false,
	true,
	false,
	true,
	false,
	true,
	true,
	false,
	false,
]
const EDGE_GRASS_POSITIONS: Array[Vector2] = [
	Vector2(1005, 557),
	Vector2(1038, 529),
	Vector2(1066, 505),
	Vector2(1099, 486),
	Vector2(1126, 459),
	Vector2(1149, 426),
	Vector2(1172, 395),
	Vector2(1189, 365),
	Vector2(1170, 335),
	Vector2(1186, 307),
	Vector2(1155, 286),
	Vector2(1121, 269),
	Vector2(1030, 581),
	Vector2(1074, 531),
	Vector2(1111, 510),
	Vector2(1155, 478),
	Vector2(1189, 432),
	Vector2(1217, 397),
]
const LOW_DETAIL_POSITIONS: Array[Vector2] = [
	Vector2(991, 269),
	Vector2(1078, 199),
	Vector2(1115, 302),
	Vector2(1244, 193),
	Vector2(1301, 277),
	Vector2(1351, 311),
	Vector2(981, 389),
	Vector2(1068, 424),
	Vector2(1234, 432),
	Vector2(1324, 474),
]
const FOREGROUND_GRASS: Array[Vector2] = [
	Vector2(1058, 627),
	Vector2(1110, 658),
	Vector2(1288, 650),
	Vector2(1349, 616),
	Vector2(1394, 676),
]


func _ready() -> void:
	var map := get_parent()
	if map == null:
		return
	map.ready.connect(_apply_finish.bind(map), CONNECT_ONE_SHOT)


func _apply_finish(map: Node) -> void:
	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	var low := map.get_node_or_null("decoration_low") as TileMapLayer
	var foreground := map.get_node_or_null("foreground_occlusion") as TileMapLayer
	if objects == null or low == null or foreground == null:
		return
	_clean_structural_noise(objects)
	_clean_legacy_decor_tiles(low, foreground)
	_hide_technical_legacy_sprites(map)
	_finish_graves(objects)
	_soften_inner_walk(map)
	_add_micro_transitions(low)
	_add_edge_grass(low)
	_add_low_detail(low)
	_add_foreground_occlusion(foreground)
	_stage_dominant_landmark(objects)


func _clean_structural_noise(objects: TileMapLayer) -> void:
	for cell: Vector2i in objects.get_used_cells():
		if CEMETERY_VISUAL_RECT.has_point(cell):
			objects.erase_cell(cell)


func _clean_legacy_decor_tiles(low: TileMapLayer, foreground: TileMapLayer) -> void:
	for cell: Vector2i in low.get_used_cells():
		low.erase_cell(cell)
	for cell: Vector2i in foreground.get_used_cells():
		foreground.erase_cell(cell)


func _hide_technical_legacy_sprites(map: Node) -> void:
	for child in map.find_children("*", "Sprite2D", true, false):
		var sprite := child as Sprite2D
		var atlas_texture := sprite.texture as AtlasTexture
		if atlas_texture == null or atlas_texture.atlas == null:
			continue
		if atlas_texture.atlas.resource_path != LEGACY_ATLAS_TEXTURE.resource_path:
			continue
		var atlas_cell := Vector2i(atlas_texture.region.position / 32.0)
		if atlas_cell in TECHNICAL_LEGACY_CELLS:
			sprite.visible = false


func _finish_graves(objects: TileMapLayer) -> void:
	for index: int in range(GRAVE_FINISH_POSITIONS.size()):
		var grave := objects.get_node_or_null("GraveVisual%02d" % index) as Sprite2D
		if grave == null:
			continue
		grave.position = GRAVE_FINISH_POSITIONS[index] - GRAVE_PIVOT
		grave.flip_h = GRAVE_FLIPS[index]


func _soften_inner_walk(map: Node) -> void:
	var walk := map.get_node_or_null("CemeteryInnerWalk") as Node2D
	if walk == null:
		return
	var edge := walk.get_node_or_null("InnerWalkEdge") as Line2D
	var fill := walk.get_node_or_null("InnerWalkFill") as Line2D
	if edge != null:
		edge.modulate.a = 0.42
	if fill != null:
		fill.modulate.a = 0.76


func _add_micro_transitions(low: TileMapLayer) -> void:
	var old_transitions := low.get_node_or_null("CommercialPathTransitions") as Node2D
	if old_transitions != null:
		old_transitions.visible = false
	if low.get_node_or_null("CommercialFinishTransitions") != null:
		return
	var transitions := Node2D.new()
	transitions.name = "CommercialFinishTransitions"
	low.add_child(transitions)
	for index: int in range(TRANSITION_POSITIONS.size()):
		_add_terrain_sprite(
			transitions,
			TRANSITION_TILES[index],
			TRANSITION_POSITIONS[index],
			"FinishTransition%02d" % index,
			TRANSITION_FLIPS[index],
			0.48,
		)


func _add_edge_grass(low: TileMapLayer) -> void:
	if low.get_node_or_null("CommercialEdgeGrass00") != null:
		return
	for index: int in range(EDGE_GRASS_POSITIONS.size()):
		_add_sprite(
			low,
			DRY_GRASS_TEXTURE,
			EDGE_GRASS_POSITIONS[index],
			DRY_GRASS_PIVOT,
			"CommercialEdgeGrass%02d" % index,
			index % 3 == 0,
		)


func _add_low_detail(low: TileMapLayer) -> void:
	if low.get_node_or_null("CommercialFinishGrass00") != null:
		return
	for index: int in range(LOW_DETAIL_POSITIONS.size()):
		_add_sprite(
			low,
			DRY_GRASS_TEXTURE,
			LOW_DETAIL_POSITIONS[index],
			DRY_GRASS_PIVOT,
			"CommercialFinishGrass%02d" % index,
			index % 3 == 1,
		)


func _add_foreground_occlusion(foreground: TileMapLayer) -> void:
	if foreground.get_node_or_null("CommercialFinishForeground00") != null:
		return
	for index: int in range(FOREGROUND_GRASS.size()):
		_add_sprite(
			foreground,
			DRY_GRASS_TEXTURE,
			FOREGROUND_GRASS[index],
			DRY_GRASS_PIVOT,
			"CommercialFinishForeground%02d" % index,
			index % 2 == 0,
		)
	_add_sprite(
		foreground,
		TREE_TEXTURE,
		Vector2(990, 684),
		TREE_PIVOT,
		"CommercialFinishForegroundTreeWest",
		false,
	)
	_add_sprite(
		foreground,
		TREE_TEXTURE,
		Vector2(1402, 690),
		TREE_PIVOT,
		"CommercialFinishForegroundTreeEast",
		true,
	)


func _stage_dominant_landmark(objects: TileMapLayer) -> void:
	var old_landmark := objects.get_node_or_null("CemeteryLandmark") as Node2D
	if old_landmark != null:
		old_landmark.visible = false
	var old_cluster := objects.get_node_or_null("CommercialMemorialCluster") as Node2D
	if old_cluster != null:
		old_cluster.visible = false
	if objects.get_node_or_null("CommercialFinishLandmark") != null:
		return
	var landmark := Node2D.new()
	landmark.name = "CommercialFinishLandmark"
	landmark.y_sort_enabled = true
	objects.add_child(landmark)
	_add_sprite(landmark, TREE_TEXTURE, Vector2(1188, 523), TREE_PIVOT, "CanopyWest", false)
	_add_sprite(landmark, TREE_TEXTURE, Vector2(1314, 526), TREE_PIVOT, "CanopyEast", true)
	_add_sprite(landmark, SIGN_TEXTURE, Vector2(1251, 574), SIGN_PIVOT, "GateSign", false)
	_add_atlas_sprite(landmark, Vector2i(1, 3), Vector2(1250, 493), "MemorialHeart", false)
	_add_sprite(
		landmark,
		DRY_GRASS_TEXTURE,
		Vector2(1234, 549),
		DRY_GRASS_PIVOT,
		"LandmarkGrassWest",
		false,
	)
	_add_sprite(
		landmark,
		DRY_GRASS_TEXTURE,
		Vector2(1271, 553),
		DRY_GRASS_PIVOT,
		"LandmarkGrassEast",
		true,
	)


func _add_atlas_sprite(
	parent: Node2D,
	atlas_cell: Vector2i,
	ground_position: Vector2,
	sprite_name: String,
	flip_h: bool,
) -> void:
	var texture := AtlasTexture.new()
	texture.atlas = LEGACY_ATLAS_TEXTURE
	texture.region = Rect2(atlas_cell * 32, Vector2i(32, 32))
	_add_sprite(parent, texture, ground_position, GRAVE_PIVOT, sprite_name, flip_h)


func _add_terrain_sprite(
	parent: Node2D,
	atlas_cell: Vector2i,
	ground_position: Vector2,
	sprite_name: String,
	flip_h: bool,
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
	sprite.flip_h = flip_h
	sprite.modulate.a = alpha
	parent.add_child(sprite)


func _add_sprite(
	parent: Node2D,
	texture: Texture2D,
	ground_position: Vector2,
	pivot: Vector2,
	sprite_name: String,
	flip_h: bool,
) -> void:
	var sprite := Sprite2D.new()
	sprite.name = sprite_name
	sprite.texture = texture
	sprite.centered = false
	sprite.position = ground_position - pivot
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.flip_h = flip_h
	parent.add_child(sprite)
