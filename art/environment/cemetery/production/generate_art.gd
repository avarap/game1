extends SceneTree

# Production cemetery art is authored, not synthesized from rectangles/noise.
# See ART_DIRECTION.md for the binding visual specification.
#
# This script intentionally performs validation only. It must never overwrite
# approved production PNGs with prototype geometry.

const OUT := "res://art/environment/cemetery/production/atlas"
const REQUIRED_ASSETS := [
	"tileset_cemetery_32.png",
	"building_workshop_exterior.png",
]


func _initialize() -> void:
	var missing: Array[String] = []
	for file_name in REQUIRED_ASSETS:
		var path := OUT.path_join(file_name)
		if not FileAccess.file_exists(path):
			missing.append(path)

	if missing.is_empty():
		print("Cemetery production art validated. No procedural assets generated.")
		quit(0)
		return

	for path in missing:
		push_error("Missing authored cemetery production asset: %s" % path)
	quit(1)
