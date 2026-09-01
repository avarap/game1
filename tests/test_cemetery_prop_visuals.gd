class_name TestCemeteryPropVisuals
extends RefCounted

const MAP_PATH := "res://world/maps/cemetery/cemetery_map.tscn"


static func run() -> Array[String]:
	var failures: Array[String] = []
	var map := (load(MAP_PATH) as PackedScene).instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(map)
	for node_path in [
		"WorkshopArea/BuildingVisualAnchor",
		"WorkshopArea/Workbench",
		"WorkshopArea/StorageChest",
		"WorkshopArea/SleepSpot",
		"CemeteryArea/CorpseDelivery",
		"CemeteryArea/PreparationTable",
		"CemeteryArea/GravePlot",
		"CemeteryArea/GraveUpgrade",
	]:
		var visual := map.get_node_or_null(node_path + "/ArtVisual") as Sprite2D
		if visual == null or visual.texture == null:
			failures.append("Cemetery prop should use raster production art: %s" % node_path)
		elif visual.centered:
			failures.append("Cemetery prop should use an explicit base pivot: %s" % node_path)
	var workshop := map.get_node_or_null("WorkshopArea/BuildingVisualAnchor/ArtVisual") as Sprite2D
	if workshop != null and workshop.position != Vector2(-160, -240):
		failures.append("Workshop visual should keep its documented ground-contact pivot")
	map.free()
	return failures
