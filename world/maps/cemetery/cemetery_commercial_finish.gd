class_name CemeteryCommercialFinish
extends Node

const TREE_TEXTURE := preload("res://art/environment/props/tree.png")
const GRAVE_WORN_TEXTURE := preload("res://art/environment/cemetery/grave_worn.png")
const SIGN_TEXTURE := preload("res://art/environment/props/sign.png")
const TERRAIN_ATLAS_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/terrain_ground_paths_32.png"
)
const LEGACY_ATLAS_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/tileset_cemetery_32.png"
)

const DRY_GRASS_PATH := "res://art/environment/cemetery/dry_grass.png"
const TREE_PIVOT := Vector2(32, 84)
const GRAVE_PIVOT := Vector2(16, 32)
const SIGN_PIVOT := Vector2(16, 32)
const TERRAIN_PIVOT := Vector2(16, 16)
const TECHNICAL_LEGACY_CELLS: Array[Vector2i] = [
	Vector2i(0, 3),
	Vector2i(2, 3),
	Vector2i(3, 3),
	Vector2i(4, 3),
]

const AUTHORED_GRAVE_POSITIONS: Array[Vector2] = [
	Vector2(1042, 254),
	Vector2(1096, 226),
	Vector2(1283, 272),
	Vector2(1328, 316),
	Vector2(1064, 404),
]
const AUTHORED_GRAVE_FLIPS: Array[bool] = [
	false,
	true,
	false,
	true,
	false,
]
const AUTHORED_GRAVE_USES_MEMORIAL: Array[bool] = [
	false,
	true,
	true,
	false,
	true,
]
const TRANSITION_POSITIONS: Array[Vector2] = [
	Vector2(1020, 566),
	Vector2(1069, 518),
	Vector2(1111, 493),
	Vector2(1158, 441),
	Vector2(1192, 390),
	Vector2(1184, 337),
	Vector2(1163, 294),
	Vector2(1122, 274),
]
const TRANSITION_TILES: Array[Vector2i] = [
	Vector2i(6, 0),
	Vector2i(1, 1),
	Vector2i(7, 0),
	Vector2i(4, 1),
	Vector2i(2, 0),
	Vector2i(6, 1),
	Vector2i(5, 0),
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
	_hide_repeated_legacy_dressing(map)
	_soften_inner_walk(map)
	_add_authored_grave_clusters(objects)
	_add_micro_transitions(low)
	_add_foreground_occlusion(foreground)
	_stage_dominant_landmark(objects)


func _clean_structural_noise(objects: TileMapLayer) -> void:
	for cell: Vector2i in objects.get_used_cells():
		objects.erase_cell(cell)


func _clean_legacy_decor_tiles(low: TileMapLayer, foreground: TileMapLayer) -> void:
	for cell: Vector2i in low.get_used_cells():
		low.erase_cell(cell)
	for cell: Vector2i in foreground.get_used_cells():
		foreground.erase_cell(cell)


func _hide_repeated_legacy_dressing(map: Node) -> void:
	for child in map.find_children("*", "Sprite2D", true, false):
		var sprite := child as Sprite2D
		if sprite.texture != null and sprite.texture.resource_path == DRY_GRASS_PATH:
			sprite.visible = false
			continue
		if sprite.name.begins_with("GraveVisual"):
			sprite.visible = false
			continue
		var atlas_texture := sprite.texture as AtlasTexture
		if atlas_texture == null or atlas_texture.atlas == null:
			continue
		if atlas_texture.atlas.resource_path != LEGACY_ATLAS_TEXTURE.resource_path:
			continue
		var atlas_cell := Vector2i(atlas_texture.region.position / 32.0)
		if sprite.name == "ArtVisual":
			if atlas_cell in TECHNICAL_LEGACY_CELLS:
				sprite.visible = false
			continue
		sprite.visible = false


func _soften_inner_walk(map: Node) -> void:
	var walk := map.get_node_or_null("CemeteryInnerWalk") as Node2D
	if walk == null:
		return
	var edge := walk.get_node_or_null("InnerWalkEdge") as Line2D
	var fill := walk.get_node_or_null("InnerWalkFill") as Line2D
	if edge != null:
		edge.modulate.a = 0.24
	if fill != null:
		fill.modulate.a = 0.56


func _add_authored_grave_clusters(objects: TileMapLayer) -> void:
	if objects.get_node_or_null("CommercialAuthoredGraves") != null:
		return
	var graves := Node2D.new()
	graves.name = "CommercialAuthoredGraves"
	graves.y_sort_enabled = true
	objects.add_child(graves)
	for index: int in range(AUTHORED_GRAVE_POSITIONS.size()):
		if AUTHORED_GRAVE_USES_MEMORIAL[index]:
			_add_atlas_sprite(
				graves,
				Vector2i(1, 3),
				AUTHORED_GRAVE_POSITIONS[index],
				"AuthoredMemorial%02d" % index,
				AUTHORED_GRAVE_FLIPS[index],
			)
		else:
			_add_sprite(
				graves,
				GRAVE_WORN_TEXTURE,
				AUTHORED_GRAVE_POSITIONS[index],
				GRAVE_PIVOT,
				"AuthoredWornGrave%02d" % index,
				AUTHORED_GRAVE_FLIPS[index],
			)


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
			0.36,
		)


func _add_foreground_occlusion(foreground: TileMapLayer) -> void:
	if foreground.get_node_or_null("CommercialFinishForegroundTreeWest") != null:
		return
	_add_sprite(
		foreground,
		TREE_TEXTURE,
		Vector2(986, 686),
		TREE_PIVOT,
		"CommercialFinishForegroundTreeWest",
		false,
	)
	_add_sprite(
		foreground,
		TREE_TEXTURE,
		Vector2(1408, 694),
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
	_add_sprite(landmark, TREE_TEXTURE, Vector2(1172, 526), TREE_PIVOT, "CanopyWest", false)
	_add_sprite(landmark, TREE_TEXTURE, Vector2(1331, 532), TREE_PIVOT, "CanopyEast", true)
	_add_atlas_sprite(landmark, Vector2i(1, 3), Vector2(1251, 478), "MemorialHeart", false)
	_add_sprite(landmark, SIGN_TEXTURE, Vector2(1252, 576), SIGN_PIVOT, "GateSign", false)


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
