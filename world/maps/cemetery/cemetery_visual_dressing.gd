class_name CemeteryVisualDressing
extends Node

const TREE_TEXTURE := preload("res://art/environment/props/tree.png")
const DRY_GRASS_TEXTURE := preload("res://art/environment/cemetery/dry_grass.png")
const TREE_PIVOT := Vector2(32, 84)
const DRY_GRASS_PIVOT := Vector2(16, 28)
const TREE_CELLS := [
	Vector2i(5, 5), Vector2i(8, 7), Vector2i(12, 5), Vector2i(15, 8),
	Vector2i(5, 13), Vector2i(8, 17), Vector2i(12, 15), Vector2i(16, 12),
	Vector2i(5, 24), Vector2i(8, 27), Vector2i(12, 28), Vector2i(17, 27),
	Vector2i(43, 5), Vector2i(46, 8), Vector2i(45, 14), Vector2i(46, 27),
]
const DRY_GRASS_CELLS := [
	Vector2i(6, 20), Vector2i(8, 21), Vector2i(10, 20), Vector2i(13, 20),
	Vector2i(16, 21), Vector2i(18, 23), Vector2i(28, 8), Vector2i(30, 10),
	Vector2i(31, 17), Vector2i(42, 18), Vector2i(44, 20), Vector2i(45, 25),
]


func _ready() -> void:
	call_deferred("_apply_dressing")


func _apply_dressing() -> void:
	var map := get_parent()
	if map == null:
		return
	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	var low := map.get_node_or_null("decoration_low") as TileMapLayer
	if objects == null or low == null:
		return

	for index in range(TREE_CELLS.size()):
		var cell: Vector2i = TREE_CELLS[index]
		objects.erase_cell(cell)
		_add_sprite(
			objects,
			TREE_TEXTURE,
			objects.map_to_local(cell),
			TREE_PIVOT,
			"TreeVisual%02d" % index,
		)

	for index in range(DRY_GRASS_CELLS.size()):
		var cell: Vector2i = DRY_GRASS_CELLS[index]
		_add_sprite(
			low,
			DRY_GRASS_TEXTURE,
			low.map_to_local(cell),
			DRY_GRASS_PIVOT,
			"DryGrassVisual%02d" % index,
		)


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
