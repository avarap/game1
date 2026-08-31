class_name MineMap
extends TechnicalMap


func _ready() -> void:
	super()
	_populate_mine_structure()


func _populate_mine_structure() -> void:
	var divider_x := 24
	for y in range(5, 26):
		if y in [10, 16, 22]:
			continue
		collision.set_cell(Vector2i(divider_x, y), SOURCE_ID, COLLISION_TILE)

	for x in range(14, 21):
		foreground_occlusion.set_cell(Vector2i(x, 8), SOURCE_ID, visual_foreground_tile)
	for x in range(31, 37):
		foreground_occlusion.set_cell(Vector2i(x, 18), SOURCE_ID, visual_foreground_tile)
