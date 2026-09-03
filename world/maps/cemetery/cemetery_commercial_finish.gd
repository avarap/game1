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

const GRAVE_FINISH_POSITIONS: Array[Vector2] = [
	Vector2(1020, 238),
	Vector2(1053, 216),
	Vector2(1099, 249),
	Vector2(1261, 226),
	Vector2(1302, 206),
	Vector2(1341, 247),
	Vector2(1278, 282),
	Vector2(1002, 350),
	Vector2(1042, 382),
	Vector2(1091, 344),
	Vector2(1308, 386),
	Vector2(1344, 426),
	Vector2(1252, 447),
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
const LOW_DETAIL_POSITIONS: Array[Vector2] = [
	Vector2(997, 261),
	Vector2(1037, 276),
	Vector2(1083, 202),
	Vector2(1115, 302),
	Vector2(1245, 195),
	Vector2(1297, 270),
	Vector2(1350, 308),
	Vector2(979, 378),
	Vector2(1070, 421),
	Vector2(1231, 425),
	Vector2(1321, 469),
]
const FOREGROUND_GRASS: Array[Vector2] = [
	Vector2(1061, 626),
	Vector2(1112, 657),
	Vector2(1288, 648),
	Vector2(1348, 612),
	Vector2(1391, 675),
]


func _ready() -> void:
	call_deferred("_apply_finish")


func _apply_finish() -> void:
	var map := get_parent()
	if map == null:
		return
	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	var low := map.get_node_or_null("decoration_low") as TileMapLayer
	var foreground := map.get_node_or_null("foreground_occlusion") as TileMapLayer
	if objects == null or low == null or foreground == null:
		return
	_finish_graves(objects)
	_soften_inner_walk(map)
	_add_micro_transitions(low)
	_add_low_detail(low)
	_add_foreground_occlusion(foreground)
	_stage_dominant_landmark(objects)


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
		edge.modulate.a = 0.62
	if fill != null:
		fill.modulate.a = 0.82


func _add_micro_transitions(low: TileMapLayer) -> void:
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
			0.78,
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
	if objects.get_node_or_null("CommercialFinishLandmark") != null:
		return
	var landmark := Node2D.new()
	landmark.name = "CommercialFinishLandmark"
	landmark.y_sort_enabled = true
	objects.add_child(landmark)
	_add_sprite(landmark, TREE_TEXTURE, Vector2(1193, 520), TREE_PIVOT, "CanopyWest", false)
	_add_sprite(landmark, TREE_TEXTURE, Vector2(1307, 526), TREE_PIVOT, "CanopyEast", true)
	_add_sprite(landmark, SIGN_TEXTURE, Vector2(1250, 574), SIGN_PIVOT, "GateSign", false)
	_add_atlas_sprite(landmark, Vector2i(1, 3), Vector2(1250, 484), "MemorialHeart", false)
	_add_atlas_sprite(landmark, Vector2i(2, 3), Vector2(1215, 518), "MemorialWest", true)
	_add_atlas_sprite(landmark, Vector2i(3, 3), Vector2(1291, 522), "MemorialEast", false)
	_add_atlas_sprite(landmark, Vector2i(0, 3), Vector2(1230, 545), "MemorialFrontWest", false)
	_add_atlas_sprite(landmark, Vector2i(2, 3), Vector2(1271, 549), "MemorialFrontEast", true)


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
