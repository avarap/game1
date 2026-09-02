class_name CemeteryLandmarks
extends TileMapLayer

const ART_SOURCE := 0
const LANDMARK_CELLS := {
	"workshop": [Vector2i(5, 23), Vector2i(4, 24), Vector2i(5, 25), Vector2i(7, 27)],
	"cemetery_threshold": [Vector2i(29, 7), Vector2i(28, 8), Vector2i(27, 9), Vector2i(26, 10)],
	"village_exit": [Vector2i(18, 2), Vector2i(17, 3), Vector2i(24, 3), Vector2i(24, 4)],
}


func _ready() -> void:
	populate(CemeteryArtTileset.build())


func populate(tile_set_resource: TileSet) -> void:
	tile_set = tile_set_resource
	collision_enabled = false
	clear()
	var variant_seed := 0
	for cluster_name in LANDMARK_CELLS:
		for cell in LANDMARK_CELLS[cluster_name]:
			set_cell(cell, ART_SOURCE, Vector2i((variant_seed + cell.x + cell.y) % 8, 2))
		variant_seed += 3
