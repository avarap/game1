class_name TestCemeteryInteractionReadability
extends RefCounted

const CEMETERY_SCENE := preload("res://world/maps/cemetery/cemetery_map.tscn")
const INTERACTION_PATHS := [
	"WorkshopArea/Workbench",
	"WorkshopArea/StorageChest",
	"WorkshopArea/SleepSpot",
	"CemeteryArea/CorpseDelivery",
	"CemeteryArea/PreparationTable",
	"CemeteryArea/GravePlot",
	"CemeteryArea/GraveUpgrade",
]


static func run() -> Array[String]:
	var failures: Array[String] = []
	var map := CEMETERY_SCENE.instantiate() as Node2D
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)
	await tree.process_frame

	var cues := map.get_node_or_null("interaction_cues") as TileMapLayer
	var collision := map.get_node_or_null("collision") as TileMapLayer
	if cues == null:
		failures.append("Rebuilt cemetery needs a dedicated interaction_cues layer")
		map.free()
		return failures
	if collision == null:
		failures.append("Interaction readability requires the collision layer")
		map.free()
		return failures

	for node_path in INTERACTION_PATHS:
		var interaction := map.get_node_or_null(node_path) as Node2D
		if interaction == null:
			failures.append("Missing interaction '%s'" % node_path)
			continue
		var center := cues.local_to_map(cues.to_local(interaction.global_position))
		var has_cue := false
		var has_safe_stand_cell := false
		for y in range(center.y - 1, center.y + 2):
			for x in range(center.x - 1, center.x + 2):
				var cell := Vector2i(x, y)
				if cues.get_cell_source_id(cell) != -1:
					has_cue = true
				if collision.get_cell_source_id(cell) == -1:
					has_safe_stand_cell = true
		if not has_cue:
			failures.append("%s needs a nearby visual interaction cue" % node_path)
		if not has_safe_stand_cell:
			failures.append("%s needs an adjacent collision-free stand cell" % node_path)

	map.free()
	return failures
